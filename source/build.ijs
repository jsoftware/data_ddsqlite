NB. build

writesourcex_jp_ '~Addons/data/ddsqlite/source';'~Addons/data/ddsqlite/ddsqlite.ijs'

(jpath '~addons/data/ddsqlite/ddsqlite.ijs') (fcopynew ::0:) jpath '~Addons/data/ddsqlite/ddsqlite.ijs'

f=. 3 : 0
(jpath '~Addons/data/ddsqlite/',y) fcopynew jpath '~Addons/data/ddsqlite/source/',y
(jpath '~addons/data/ddsqlite/',y) (fcopynew ::0:) jpath '~Addons/data/ddsqlite/source/',y
)

mkdir_j_ jpath '~Addons/data/ddsqlite/test'
mkdir_j_ jpath '~addons/data/ddsqlite/test'

f 'manifest.ijs'
f 'history.txt'
f 'readme.txt'
f 'test/test1.ijs'
f 'test/test2.ijs'
