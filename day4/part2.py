f_name = "input.txt"
lines = open(f_name).readlines()

def to_nlist(l):
    lnraw = filter(lambda x: x!='', l.split(" "))
    return list(map(int, lnraw))

nlst = [0]*500

def proc_line(l):
    (win, stack) = l.split(":")[-1].split("|")
    win, stack = to_nlist(win), to_nlist(stack)
    i = 0
    for n in stack:
        if n in win:
            i+=1
    return i

for i in range(len(lines)):
    nlst[i] = 1

s = 0
for i in range(len(lines)):
    l = lines[i]
    res = proc_line(l)
    for j in range(res):
        nlst[i+j+1] += nlst[i]

print(sum(nlst))
