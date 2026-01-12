---
layout: post
---

Embedded Programming Interview Prep

# C programming

- Keywords

volatile: Prevents optimization
restrict: Allows optimization but while preventing pointer aliasing
const: Restricts writing

- Signed integer + left shift (<<) is chaotic, mostly because overflowing

~~~c
#include <stdio.h>
#include <stdint.h>
#include <limits.h> // CHAR_BIT

void print_b(const int32_t num)
{
    const int bitnr = sizeof(int) * CHAR_BIT;
    for (int i = bitnr - 1; i >= 0; i--) {
        int b = (num >> i) & 1;
        printf("%d", b);
    }
    printf("\n");
}

int main()
{
    int32_t num = 1099020398;
    while (num) {
        printf("number: %d\n", num);
        print_b(num);
        num <<= 1;
    }
    return 0;
}
~~~

In the output we can see that shifting 1099020398 left creates overflowing and made it a negative number

~~~sh
c $ gcc shift_signed.c && ./a.out
number: 1099020398
01000001100000011011100001101110
number: -2096926500
10000011000000110111000011011100
~~~


Bit-manipulation related built-ins
~~~c
num = 11;
// count 1 bits
__builtin_popcount(num);

// leading zeros
__builtin_clz(num);

// trailing zeros
__builtin_ctz(num);

// reverse num
__builtin_reverse32(num);
~~~

static: for variables, it keeps its value between invocations; For functions and global variables, it makes it only
visible in this translation unit (current file).

difference between linked list and array: 
array is contiguous and fast for sequential read, linked list is fast for insertion and deletion but slow for
sequential read


---

const pointers

~~~c
const char *p; // p itself writable, its data not writable
const char *const p; // p not writable, its data not writable
~~~

---

printf tips:
- Use ~%.\*s~ to specify the length of string (like a float)
- ~%hhd~ to print a char like an int

How post increment works? You use the value first and increment it.

How does breakpoint work? Trap instruction + ptrace

# CPP (somehow)

Inheritance: Reuse the code

Virtual functions: Runtime polymorphism. Functions are declared using virtual
keyword in the base class. Function resolution happens during runtime.

~~~cpp
#include <cstdio> // for std::printf wrapped in std namespace
~~~

# Embedded & OS knowledge

Watchdog timer: detects anomalies and reset CPU if any occur

Virtual memory:
- isolation
- more memory in RAM via disk paging

Priority Inversion:
Mid pri task runs to transfer right of running from low pri task to high pri
task. (to make low pri not preemptible, just make it high so mid can't preempt)

Reentrancy: If can resume after interruption
> Can't use global / static data

Spinlock: Consumes CPU to wait for a resource

Atomic ops:
atomic ops are isolated from other ops

Concurrency: Run A, and run B, may not be simultaneous
Parallelism: Running at the same time, has to be mult-core

Thread vs Process: process has all the resources, especially heap. Thread has its own stack but not heap.

Mutex vs Semaphores: 
- Mutex is for accessing resources, binary semaphores is used for synchronization
- Semaphores signal between tasks, a task doesn't take and give it all by itself

Thrashing? Excessive paging?
- Have virtual memory > RAM size, so OS is constantly swapping pages to disk

What is dynamic loading, what is static loading, when to use them?

Dynamic loading is when code is loaded into memory dynamically.
Static loading is done at compile time.

Difference between regular OS and RTOS
- RTOS is used for time-critical systems
- Task scheduling in RTOS is priority-based
- kernels in RTOS are preemptible

What is mutual exclusion?
When two processes try to enter a critical region, one will be blocked

Priorities of OS programs? (ARM)
EL0 - General application
EL1 - OS
EL2 - Hypervisor
EL3 - Security stuff

Critical region
If accessed without mutual exclusion, will introduce race conditions.
Typical critical region resources:
- Global variables
- queues, pools, ring buffers
- I/O devices

what happens in the background from the time you press the Power button until the Linux login prompt
Power ON -> BIOS -> MBR (Master Boot Record) -> Boot Loader (GRUB) -> Kernel (Linux obviously) -> Initial RAM disk
-> /sbin/init (parent process) -> shell -> X windows system

What does a bootloader do?
Setup stack and memory mapping, load the OS image and hand it over to OS.

---

Elevator ISR

Button -> ISR

Elevator Control:
- Scheduler
- State Machine

Motor / Door

FSM:

~~~c
enum elevator_state {
    IDLE,
    MOVING_UP,
    MOVING_DOWN,
    DOOR_OPEN,
    DOOR_CLOSED,
    EMERGENCY_STOP
};
~~~

If moving UP: Serve all requests moving above the current
up dest. Ignore downward requests until no more upward requests.

If moving DOWN: Serve all downwards <= current and ignore upwards.

If IDLE: Pick nearest request, choose direction.

request tracking:

~~~c
bool inside_request[N];
bool up_request[N];
bool down_request[N];
~~~

ISR:
- identify button
- record request
- signal main loop

~~~c
void button_isr(int floor, int direction) {
    request[floor][direction] = true;
    event_flag = 1;
}
~~~

Main control loop:

~~~c
while (1) {
    if (event_flag) {
        update_targets();
        event_flag = 0;
    }

    switch (state) {
        case MOVING_UP:
            move_up();
            if (stop_needed())
                open_door();
            break;
        case MOVING_DOWN:
            move_down();
            break;
        case DOOR_OPEN:
            wait();
            close_door();
            break;
    }
}
~~~

ISR -> signal, main loop -> decision.

---

What is ISR and ISR vector table?
ISR is a way to save the current context, execute an
interrupt, and jump back and resume 

ISR addresses are stored in the ISR vector table

Memory map of program
- bss: uninitialized data
- rodata: read-only data
- data: initialized data
- text: code

If we declare more number of variables than the registers available on the processor? Where they will be stored.
stack


Memory alignment
- char 1 byte
- short 2 bytes
- int 4 bytes
- double 8 bytes
- pointer 4 bytes on 32-bit machine, 8 bytes on 64-bit machine
- Memory is padded to nearest multiple

Diff between macros and inline
inline variable types are checked, more debuggable

How do you send data over the network between two machines with different endianess 
~~~c
#define bswap(num)                  \
(                                   \
     (((num) & 0xff000000) >> 24) | \
     (((num) & 0x00ff0000) >> 8) |  \
     (((num) & 0x0000ff00) << 8) |  \
     (((num) & 0x000000ff) << 24)   \
)
~~~

alignment

~~~
// align has to be the power of 2
int align(int num, int align)
{
    return (num + (align - 1)) & ~(align - 1);
}
~~~


What are interrupts and if you have less external interrupt pins on a
processor, how to interface multiple interrupts?

CPU has to save the execution context and switch to executing the interrput in ISR.
Use a Interrupt handler that prioritizes the interrupts.

UART
- serial data
- two wires: Rx & Tx
No clock signal to synchronize the data, add start and stop bits to identify, both UART ports have to
operate at similar baud rate
doesn't support multiple masters/slaves, just two devices

SPI
- serial peripheral interface
- one master can control multiple slaves
- MISO (master in slave out), MOSI, CLK (clock), SS (slave select)
- data can be streamed continuously, no start/stop bits

I2C
- two pins: SDA (serial data) SCL (serial clock)
- synchronized to the clock signal
- start + address frame + ACK + data frames + ACK + stop

What techniques would you use to reduce power consumption in an embedded system?
- Sleep mode
- No busy waiting, triggers execution using interrupts
- DMA

What kind of data structure you will use to store data from a serial receive line?
- Queue (FIFO)

What are some ways in which UART can have communication error?
- Clock skew
- noise
- receiver too slow, receiver buffer is full

extern keyword
- No allocation, declared somewhere else, shared between translation units

debounce impl
~~~c
#include <stdio.h>
#define DEBOUNCE_MS 32
 
bool stable;
bool laststate;
uint32_t lasttime;
 
void debounce()
{
    bool curstate = read_button();
    if (curstate != laststate) {
        lasttime = millis();
    }
    laststate = curstate;
 
    if (millis() - lasttime > DEBOUNCE_MS) {
        if (curstate != stable) {
            stable = curstate;
            handle_event(stable);
        }
    }
}                                                                                                                    
 
int main()
{
    while (1)
        debounce();
    return 0;
}
~~~


