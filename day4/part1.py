f_name = "input.txt"
lines = open(f_name).readlines()

def to_nlist(l):
    lnraw = filter(lambda x: x!='', l.split(" "))
    return list(map(int, lnraw))

def proc_line(l):
    (win, stack) = l.split(":")[-1].split("|")
    win, stack = to_nlist(win), to_nlist(stack)
    i = 0
    for n in stack:
        if n in win:
            i+=1
    return int(2**(int(i-1)))

s = 0
for l in lines:
    s+=proc_line(l)

print(s)
