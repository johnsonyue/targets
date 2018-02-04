#!/bin/bash

get(){
cl=$(
cat << "EOF"
TW
HK
IR
PK
SY
IQ
AF
LY
EOF
)

tl=$(
cat << "EOF"
aiwen_data
ip2location_data
ip2locationlite_data
maxmind_data
EOF
)

for c in ${cl[@]}; do
  for t in ${tl[@]}; do
   echo "python country_query.py -c $c -t $t -o $c.$t"
   python country_query.py -c $c -t $t -o $c.$t
  done
done
}

aggr(){
export LC_COLLATE=C #otherwise [A-Z] will not be case-sensitive
ls [A-Z][A-Z].* | sort | xargs -I {} bash -c "echo \#{}; cat {}; echo" | python <(
cat << "EOF"
import json
d={}
j=""
while True:
  try:
    l=raw_input().strip()
  except:
    break
  if not l:
    continue
  if l[0]=='#':
    if j:
      o=json.loads(j)
      if not d.has_key(f[0]):
        d[f[0]]={}
      d[f[0]][f[1]]=o
      j=""
    f=l.lstrip('#').split('.')
  else:
    j+=l
print json.dumps(d)
EOF
)
}

check(){
python <(
cat << "EOF"
import sys
import json
o=json.loads(sys.stdin.read())
for k,v in o.items():
  if type(v) == type({}):
    for vk,vv in v.items():
      print k + ": " + vk + ", " + str(len(vv))
  elif type(v) == type([]):
    print k + ": " + "intersect, " + str(len(v))
EOF
)
}

inter(){
python <(
cat << "EOF"
import sys
import json

d={}
o=json.loads(sys.stdin.read())
for k,v in o.items(): #k is country
  d[k]=[]
  l={}
  for vk in v.keys(): #vk is database
    v[vk].sort(key=lambda x:x["ip_from"])
    l[vk]=[0,0]
  m=[]
  while True: #merge
    cm=float('inf')
    p=""
    ck=""
    clear=True
    for vk in v.keys():
      if l[vk][0] >= len(v[vk]):
        continue
      clear=False
      f=v[vk][l[vk][0]]["ip_from"]
      t=v[vk][l[vk][0]]["ip_to"]
      if not l[vk][1] and f<cm:
        cm=f
        p='f'
        ck=vk
      elif t<cm:
        cm=t
        p='t'
        ck=vk
      
    if clear:
      break
    if p=='f':
      l[ck][1]=1
    else:
      l[ck][0]+=1
      l[ck][1]=0
    m.append([cm,p])

  cf=0
  for i in range(len(m)):
    if m[i][1]=='f':
      cf+=1
    else:
      if cf==len(v.keys()):
        d[k].append({"ip_from":m[i-1][0], "ip_to":m[i][0]})
      cf-=1
print json.dumps(d)
EOF
)
}

gen(){
g=$1
python <(
cat << "EOF"
import sys
import json
import socket
import struct

def ip_int2str(i):
  return socket.inet_ntoa(struct.pack('!L',i)) 

o=json.loads(sys.stdin.read())
g=int(sys.argv[1])
for k,v in o.items():
  for vv in v:
    for i in range(vv['ip_from'],vv['ip_to']+1,2**(32-g)):
      print ip_int2str(i)
EOF
) $g
}

#get
aggr > aggr
cat aggr | inter > inter
cat aggr | check
cat inter | check

cat inter | gen 28 >targets 
