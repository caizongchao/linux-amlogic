/*
 * drivers/amlogic/media/vin/tvin/tvafe/tvafe_avin_detect.h
 *
 * Copyright (C) 2017 Amlogic, Inc. All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 */

#ifndef TVAFE_AVIN_DETECT_H_
#define TVAFE_AVIN_DETECT_H_

#include <linux/cdev.h>
#include <linux/workqueue.h>
#include <linux/mutex.h>


#define HHI_CVBS_DETECT_CNTL	0x2e
#define AFE_DETECT_RSV3_BIT		31
#define AFE_DETECT_RSV3_WIDTH	1
#define AFE_DETECT_RSV2_BIT		30
#define AFE_DETECT_RSV2_WIDTH	1
#define AFE_DETECT_RSV1_BIT		29
#define AFE_DETECT_RSV1_WIDTH		1
#define AFE_DETECT_RSV0_BIT		28
#define AFE_DETECT_RSV0_WIDTH		1
#define AFE_CH2_SYNC_HYS_ADJ_BIT	13
#define AFE_CH2_SYNC_HYS_ADJ_WIDTH	2
#define AFE_CH2_SYNC_LEVEL_ADJ_BIT	10
#define AFE_CH2_SYNC_LEVEL_ADJ_WIDTH	3
#define AFE_CH2_EN_SYNC_TIP_BIT		9
#define AFE_CH2_EN_SYNC_TIP_WIDTH	1
#define AFE_CH2_EN_DETECT_BIT		8
#define AFE_CH2_EN_DETECT_WIDTH		1
#define AFE_CH1_SYNC_HYS_ADJ_BIT	5
#define AFE_CH1_SYNC_HYS_ADJ_WIDTH	2
#define AFE_CH1_SYNC_LEVEL_ADJ_BIT	2
#define AFE_CH1_SYNC_LEVEL_ADJ_WIDTH	3
#define AFE_CH1_EN_SYNC_TIP_BIT		1
#define AFE_CH1_EN_SYNC_TIP_WIDTH	1
#define AFE_CH1_EN_DETECT_BIT		0
#define AFE_CH1_EN_DETECT_WIDTH		1

#define CVBS_IRQ0_CNTL			0x3c24
#define CVBS_IRQ_MODE_BIT		6
#define CVBS_IRQ_MODE_WIDTH		3
#define CVBS_IRQ_MODE_MASK		7
#define CVBS_IRQ_TRIGGER_SEL_BIT	5
#define CVBS_IRQ_TRIGGER_SEL_WIDTH	1
#define CVBS_IRQ_TRIGGER_SEL_MASK	1
#define CVBS_IRQ_EDGE_EN_BIT		4
#define CVBS_IRQ_EDGE_EN_WIDTH		1
#define CVBS_IRQ_EDGE_EN_MASK		1
#define CVBS_IRQ_FILTER_BIT		1
#define CVBS_IRQ_FILTER_WIDTH		3
#define CVBS_IRQ_FILTER_MASK		7
#define CVBS_IRQ_POL_BIT		0
#define CVBS_IRQ_POL_WIDTH		1
#define CVBS_IRQ_POL_MASK		1

#define CVBS_IRQ1_CNTL			0x3c25
#define CVBS_IRQ0_COUNTER		0x3c26
#define CVBS_IRQ1_COUNTER		0x3c27


enum tvafe_avin_status_e {
	TVAFE_AVIN_STATUS_IN = 0,
	TVAFE_AVIN_STATUS_OUT = 1,
	TVAFE_AVIN_STATUS_UNKNOWN = 2,
};
enum tvafe_avin_channel_e {
	TVAFE_AVIN_CHANNEL1 = 0,
	TVAFE_AVIN_CHANNEL2 = 1,
};

struct tvafe_report_data_s {
	enum tvafe_avin_channel_e channel;
	enum tvafe_avin_status_e status;
};

struct tvafe_dts_const_param_s {
	unsigned int device_mask;/*bit0:av1;bit1:av2*/
	/*when mask==3,sequence 0:bit0->av1 bit1->av2;1:bit0->av2 bit1->av1*/
	unsigned int device_sequence;
	unsigned int irq[2];
};

struct tvafe_avin_det_s {
	char config_name[20];
	dev_t  avin_devno;
	struct device *config_dev;
	struct class *config_class;
	struct cdev avin_cdev;
	struct tvafe_dts_const_param_s dts_param;
	struct tvafe_report_data_s report_data_s[2];
	struct work_struct work_struct_update;
	unsigned int irq_counter[2];
	unsigned int device_num;
};

void tvafe_cha1_SYNCTIP_close_config(void);
void tvafe_cha2_SYNCTIP_close_config(void);
void tvafe_cha1_2_SYNCTIP_close_config(void);
void tvafe_cha1_detect_restart_config(void);
void tvafe_cha2_detect_restart_config(void);

#endif /* TVAFE_AVIN_DETECT_H_ */

