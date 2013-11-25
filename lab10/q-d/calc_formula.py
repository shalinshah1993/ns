import math

RTT = 0.2
S = 500.0
RWND = 10000

p = input("Enter the value of p :-")
for1 = (S/RTT) * math.sqrt(3.0/(4.0 * p))
for2 = min(RWND/RTT, S/(RTT * (math.sqrt((4.0/3.0) * p) + 4.0 * min(1, 3.0 * math.sqrt((6.0/8.0) * p)) * p * (1 + 32 * p * p))))

print "Throughput1", for1
print "Throughput2", for2


