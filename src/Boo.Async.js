/*global Boo: false, setImmediate: false, setTimeout: false */

Boo.define('Async', ['exports', 'Boo'], function (exports, Boo) {
    'use strict';

    var DeferredState = {
        Unresolved: 0,
        Resolved: 1,
        Rejected: 2,
        Cancelled: 3
    };

    // Find the best implementation for the enqueue (next-tick) function
    var enqueue = (typeof process === 'object' && typeof process.nextTick === 'function')
                ? process.nextTick
                // http://dvcs.w3.org/hg/webperf/raw-file/tip/specs/setImmediate/Overview.html
                : (typeof setImmediate === 'function')
                ? setImmediate
                : function (cb) { setTimeout(cb, 0); };

    function Promise(deferred) {
        return {
            cancel: function () {
                deferred.cancel();
            },
            then: function (ok, error, progress) {
                return deferred.then(ok, error, progress);
            },
            done: function (fn) {
                return deferred.then(fn);
            },
            fail: function (fn) {
                return deferred.then(null, fn);
            },
            always: function (fn) {
                return deferred.then(fn, fn);
            }
        };
    }

    function Deferred(cancel) {
        if (!(this instanceof Deferred)) {
            return new Deferred(cancel);
        }

        var result = null,
            state = DeferredState.Unresolved,
            waiting = [],
            promise = Promise(this);

        function notifyAll(value, rejected) {
            if (state === DeferredState.Cancelled) {
                return;
            } else if (state !== DeferredState.Unresolved) {
                throw new TypeError("deferred is already resolved (state is " + state + ")");
            }

            state = rejected ? DeferredState.Rejected : DeferredState.Resolved;
            result = value;
            for (var i = 0; i < waiting.length; i++) {
                rejected = rejected && !waiting[i].reject;
                notify(waiting[i]);
            }

            // Notify errors not caught by any reject handler
            if (rejected) {
                Deferred.onError(result, promise);
            }

            waiting = null;
        }

        function notify(listener) {
            var func = state === DeferredState.Rejected ? listener.reject : listener.resolve;
            if (func) {
                enqueue(function () {
                    try {
                        listener.next.resolve(func(result));
                    } catch (e) {
                        listener.next.reject(e);
                    }
                });
            } else if (state === DeferredState.Rejected) {
                listener.next.reject(result);
            } else {
                listener.next.resolve(result);
            }
        }

        this.promise = promise;

        this.getState = function () {
            return state;
        };

        this.resolve = function (value) {
            notifyAll(value, false);
        };

        this.reject = function (error) {
            notifyAll(error, true);
        };

        this.progress = function (update) {
            for (var i = 0; i < waiting.length; i++) {
                if (waiting[i].progress) {
                    waiting[i].progress(update);
                }
            }
        };

        this.cancel = function () {
            state = DeferredState.Cancelled;
            waiting = null;
            if (typeof cancel === 'function') {
                cancel();
            }
        };

        this.then = function (ok, error, progress) {
            var listener = {
                    next: new Deferred(cancel),
                    resolve: ok,
                    reject: error,
                    progress: progress
                };

            if (state !== DeferredState.Unresolved) {
                notify(listener);
            } else {
                waiting.push(listener);
            }

            return listener.next.promise;
        };
    }

    // Handles unhandled rejections system wide
    Deferred.onError = function (error, promise) {
        throw error;
    };

    // Wraps a generator in a function that will consume it while resolving yielded
    // promises, implementing this way a coroutine.
    // Returns a promise which can be subscribed to in order to chain and mix async
    // operations.
    function async(fn) {
        var defer = new Deferred(),
            generator = fn();

        function consume(value, is_error) {
            var result;
            try {
                if (is_error) {
                    result = generator['throw'](value);
                } else {
                    result = generator.send(value);
                }

                // Handle immediate values
                if (!result || typeof result.then !== 'function') {
                    result = when(result);
                }

                // Register the continuation for the generator
                result.then(function (v) { consume(v); }, function (e) { consume(e, true); });
            } catch (e) {
                generator.close();
                if (e === Boo.STOP) {
                    defer.resolve(value);
                } else {
                    defer.reject(e);
                }
            }
        }

        // Initiate the asynchronous task
        consume();
        return defer.promise;
    }

    function when(promises) {
        // Detect arrays and array like objects
        var is_array = true;
        if (typeof promises !== 'object' || promises.length !== +promises.length) {
            promises = [promises];
            is_array = false;
        }

        var n = promises.length,
            remaining = n,
            result = new Array(n),
            pending = new Array(n),
            defer;

        function cancel() {
            if (defer.getState() !== DeferredState.Unresolved) {
                return;
            }

            for (var i = 0; i < n; i++) {
                if (pending[i]) {
                    pending[i].cancel();
                }
            }
        }

        defer = new Deferred(cancel);
        if (n === 0) {
            defer.resolve(is_array ? result : result[0]);
        }

        Boo.each(Boo.range(n), function (i) {
            var p = promises[i];

            // Immediately resolve those values that are not promises
            if (!p || typeof p.then !== 'function') {
                var tmp = new Deferred();
                p = tmp.promise;
                tmp.resolve(promises[i]);
            }

            pending[i] = p;

            p.then(function (value) {
                remaining -= 1;
                pending[i] = null;
                if (defer.getState() !== DeferredState.Unresolved) {
                    return;
                }
                result[i] = value;
                if (remaining === 0) {
                    defer.resolve(is_array ? result : result[0]);
                }
            }, function (error) {
                pending[i] = null;
                if (defer.getState() !== DeferredState.Unresolved) {
                    return;
                }
                cancel();
                defer.reject(error);
            });
        });

        return defer.promise;
    }

    function sleep(ms, callback) {
        function check() {
            var elapsed = +(new Date()) - start;
            if (elapsed < ms) {
                // Browsers and NodeJS support the setTimeout global function
                id = setTimeout(check, ms - elapsed);
                return;
            }
            id = null;
            defer.resolve(elapsed);
        }

        var defer = new Deferred(function () {
                if (id) { clearTimeout(id); id = null; }
            }),
            start = +(new Date()),
            id = setTimeout(check, ms);

        if (callback) {
            defer.then(callback);
        }

        return defer.promise;
    }

    // Expose public API
    exports.Deferred = Deferred;
    exports.DeferredState = DeferredState;
    exports.enqueue = enqueue;
    exports.async = async;
    exports.when = when;
    exports.sleep = sleep;
});
