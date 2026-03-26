// See LICENSE for license details.
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include "hbird_sdk_soc.h"
#include "insn.h"
#include "image_data.h"
#include "imagenet_128x128.h"

int main(void)
{
   /************config_spike_encoder*****************/
	unsigned int cfg_spike_encoder[12] = {
	    20, 10, 7,                 // cfg_sigma：{sigma1,sigma2,threshold}
	    0, 0, 16, 1, 16,           // cfg_code_mode：{encode_mode,image_type,Tmax,Tmin,poission_max_pulse_num}
	    0, 1, 28, 28               // cfg_input_size：{batch_size,rgb_channel,rowe,cols}
	};

	//encode_mode: 0:poiss, 1:TTFS, 2:ISI
	//image_type：0:source image 1:guiss_differ_image
	//cfg_input_size:
	//               MNIST:   0,1,28,28
	//               CIFAR10: 0,3,32,32
	//               IMAGENET:0,1,128,128

	config_spike_encoder((int) cfg_spike_encoder);
	fence();

   /************read source image(hex)***************/
   //load_img((int)img_0_3);     //CIFAR10 data
   load_img((int)memory);        //MNIST data
   //load_img((int)img1_r_128x128);    //IMAGENET data

   printf("************spike encode finish!!!*************\n");

   return 0;
}





