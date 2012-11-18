/*global Boo: false, setImmediate: false, setTimeout: false */

Boo.define('Async', ['exports', 'Boo'], function (exports, Boo) {
    'use strict';

    var DeferredState = {
        Unresolved: 0,
        Resolved: 1,
        Rejected: 2,
        Cancelled: 3
    };

    var enqueue = (typeof process === 'object' && typeof process.nextTick === 'function')
                ? process.nextTick
                : (typeof setImmediate === 'function')
                // http://dvcs.w3.org/hg/webperf/raw-file/tip/specs/setImmediate/Overview.html
                ? setImmediate
                : function (cb) { setTimeout(cb, 0); };

    function Promise(deferred) {
        return {
            then: function (ok, error, progress) {
                return deferred.then(ok, error, progress);
            },
            cancel: function () {
                deferred.cancel();
            },
            done: function (fn) {
                deferred.then(fn);
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
            waiting = [];

        function notifyAll(value, rejected) {
            if (state === DeferredState.Cancelled) {
                return;
            } else if (state !== DeferredState.Unresolved) {
                throw new TypeError("deferred is already resolved (state is " + state + ")");
            }

            state = rejected ? DeferredState.Rejected : DeferredState.Resolved;
            result = value;
            for (var i = 0; i < waiting.length; i++) {
                notify(waiting[i]);
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


        this.promise = Promise(this);

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

                // Handle multiple promises
                if (result && result.length === +result.length) {
                    result = when(result);
                }

                if (!result || typeof result.then !== 'function') {
                    throw new TypeError('The value yielded from the generator is not a Promise');
                }

                // Register the continuation for the generator
                result.then(function (v) { consume(v); }, function (e) { consume(e, true); });

            } catch (e) {
                generator.close();
                if (e === Boo.StopIteration) {
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
            defer.resolve(result);
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
                    defer.resolve(result);
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

    function sleep(ms) {
        function check() {
            var elapsed = +(new Date()) - start;
            if (elapsed < ms) {
                ref = setTimeout(check, ms - elapsed);
                return;
            }
            defer.resolve(elapsed);
        }

        var defer = new Deferred(),
            start = +(new Date()),
            ref = setTimeout(check, ms);

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
