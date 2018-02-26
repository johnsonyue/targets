import sys
import socket
import struct

#sub
def ip_str2int(ip):
  packedIP = socket.inet_aton(ip)
  return struct.unpack("!L", packedIP)[0]

def ip_int2str(i):
	return socket.inet_ntoa(struct.pack('!L',i)) 

def dfs(p,pi,n):
  if pi != -1 and el[pi][3] == 1:
    return 1
  if el[pi][2] == 1 or el[pi][1] in p:
    return 0
  if n in dl:
    el[pi][3] = 1
    print ip_int2str(el[pi][0]),ip_int2str(el[pi][1])
    return 1

  is_sup = False
  if ind.has_key(n):
    i = ind[n]
    while i<len(el) and el[i][0] == n:
      if (dfs(p + [n], i, el[i][1])):
        is_sup = True
      i+=1

  if pi != -1:
    if is_sup:
      el[pi][3] = 1
      print ip_int2str(el[pi][0]),ip_int2str(el[pi][1])
      return 1
    else:
      el[pi][2] = 1
      return 0

#main
sl = map(ip_str2int, sys.argv[1].split()) #source list
dl = map(ip_str2int, sys.argv[2].split()) #destination list

el = [] #edge list
while True:
  try:
    line=raw_input().strip()
  except:
    break
  fl=line.split()
  el.append([ip_str2int(fl[0]),ip_str2int(fl[1]),0,0])

p = -1 #previous src
ind = {} #node index
for i in range(len(el)):
  e = el[i]
  if e[0] != p:
    ind[e[0]] = i
  p=e[0]

for s in sl:
  dfs([],-1,s)
