#imple assembly program that will cause Spike to terminate gracefully.

.text
  .global _start

_start:
	
        #li a0
        #li a0, 1
        addi a1, zero ,0 
        addi t2, zero, 2
        addi t0, zero, 0
    	addi t1, zero, 1
    	addi a0, zero, 7
        addi t3, zero, 1 
        BEQ a0, zero, EXIT	
JUMP: 	add a1, t0, t1
        add t0, t1, zero
        add t1, a1, zero
        addi t2, t2 ,1
        SLT t3, a0, t2
        BEQ t3, zero, JUMP
EXIT:  

  # Write the value 1 to tohost, telling Spike to quit with an exit code of 0.
  li t0, 1
  la t1, tohost
  sw t0, 0(t1)

  # Spin until Spike terminates the simulation.
  1: j 1b

# Expose tohost and fromhost to Spike so we can communicate with it.
.data
  .global tohost
tohost:   .dword 0
  .global fromhost
fromhost: .dword 0


