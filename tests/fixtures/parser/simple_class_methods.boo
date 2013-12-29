"""
title body tag
"""
namespace ITL.Content


class Article:
	def getTitle() as string:
		return 'title'

	def getBody() as string:
		return 'body'

	def getTag():
		return 'tag'


a = Article()
print a.getTitle(), a.getBody(), a.getTag()
