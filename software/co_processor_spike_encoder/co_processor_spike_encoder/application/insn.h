#ifndef __INSN_H__
#define __INSN_H__

#include "hbird_sdk_soc.h"

__STATIC_FORCEINLINE void fence()
{
    asm volatile (
       "fence.i"
           :
           :
     );
}

__STATIC_FORCEINLINE void config_spike_encoder(int addr)
{
    int zero = 0;

    asm volatile (
       ".insn r 0x7b, 2, 0, x0,%1, x0"
             :"=r"(zero)
             :"r"(addr)
     );
}

__STATIC_FORCEINLINE void load_img(int addr)
{
    int zero = 0;

    asm volatile (
       ".insn r 0x7b, 2, 1, x0,%1, x0"
             :"=r"(zero)
             :"r"(addr)
     );

}

__STATIC_FORCEINLINE void spike_finish_rd(int addr)
{
    int zero = 0;

    asm volatile (
       ".insn r 0x7b, 2, 3, x0,%1, x0"
             :"=r"(zero)
             :"r"(addr)
     );

}

__STATIC_FORCEINLINE void imagenet_spike_finish(int addr)
{
    int zero = 0;

    asm volatile (
       ".insn r 0x7b, 2, 14, x0,%1, x0"
             :"=r"(zero)
             :"r"(addr)
     );

}



#endif

