import os
import collections
def init_checkList():
	names = os.listdir('./imageData')
	if '.DS_Store' in names:
		names.remove('.DS_Store')

	checkList = {}
	for n in names:
		checkList[n] = False

	checkList = collections.OrderedDict(sorted(checkList.items()))
	for x,y in checkList.iteritems():
		print(x,y)
	return checkList
print(init_checkList())