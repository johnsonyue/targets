union(){
python <(
cat << "EOF"
#sub
def find(x):
  if not sets.has_key(x):
    sets[x] = [x,0]
    return x
  
  if sets[x][0] == x:
    return x
  else:
    return find(sets[x][0])

def union(x,y):
  rx = find(x)
  ry = find(y)
  if rx == ry:
    return
  if sets[rx][1] < sets[ry][1]:
    sets[rx][0] = ry
  elif sets[rx][1] > sets[ry][1]:
    sets[ry][0] = rx
  else:
    sets[ry][0] = rx
    sets[rx][1] += 1

#main
sets={}
while True:
  try:
    line=raw_input().strip()
  except:
    break
  f=line.split()
  union(f[0],f[1])

#out
d={}
for k in sets.keys():
  r=find(k)
  if not d.has_key(r):
    d[r] = [k]
  else:
    d[r].append(k)
for v in d.values():
  print ' '.join(sorted(v))
EOF
)
}

sub(){
python <(
cat << "EOF"
d={}

def find(x):
  if d.has_key(x):
    return d[x]
  return x

while True:
  line=raw_input().strip()
  if line=="#":
    break
  f=line.split()
  for i in f:
    d[i] = f[0]

while True:
  try:
    line=raw_input().strip()
  except:
    break
  f=line.split()
  print find(f[0]),find(f[1]),' '.join(f[2:])
EOF
) | sort -k 1,2 --parallel 4
}

merge(){
python <(
cat << "EOF"
def merge_attrs(al,bl): #overwrite
  al[0] = str(int(al[0])+int(bl[0]))
  if float(bl[1]) < float(al[1]):
    al[1] = bl[1]
  return al

p=[]
while True:
  try:
    line=raw_input().strip()
  except:
    break
  if not line:
    continue

  f=line.split()
  if f[:2] == p[:2]:
    print ' '.join(f[:2]+merge_attrs(f[2:],p[2:]))
  p=f
EOF
)
}

cat <(cat test | union) <(echo '#') test2 | sub | merge
