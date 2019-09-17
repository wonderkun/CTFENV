
import os
import ptvsd

print("Waiting for debugger attach at %s:%s ......" % ('127.0.0.1',3000))
ptvsd.enable_attach(address=('0.0.0.0', 3000))
ptvsd.wait_for_attach()

os.system('ls')
for i in range(100):
    print(i)