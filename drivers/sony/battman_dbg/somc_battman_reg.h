// SPDX-License-Identifier: GPL-2.0-only
/*
 * Copyright (c) 2019-2020, The Linux Foundation. All rights reserved.
 */

#define SPMI_BUS_ID			0
#define PMIC_SLAVE_ID			3

/*CHGR reg address*/
#define CHGR_BASE				0x2600
#define CHGR_CHARGER_STATUS_REG			0x06
#define CHGR_VBAT_STATUS_REG			0x08
#define CHGR_VBAT_STATUS2_REG			0x09
#define CHGR_IBAT_STATUS_REG			0x0A
#define CHGR_VFLT_STATUS_REG			0x0B
#define CHGR_ICHG_STATUS_REG			0x0E
#define CHGR_INT_RT_STS_REG			0x10
#define CHGR_CHG_EN_REG				0x46
#define CHGR_ICHG_CFG_REG			0x54
#define CHGR_VFLT_CFG_REG			0x58

/*DCDC reg address*/
#define DCDC_BASE				0x2700
#define DCDC_ICL_MAX_STATUS_REG			0x06
#define DCDC_ICL_AICL_STATUS_REG		0x07
#define DCDC_ICL_STATUS_REG			0x09
#define DCDC_POWER_PATH_STATUS_REG		0x0B
#define DCDC_BST_STATUS_REG			0x0D
#define DCDC_INT_RT_STS_REG			0x10

/*BATIF reg address*/
#define BATIF_BASE				0x2800
#define BATIF_BAT_TEMP_STATUS_REG		0x0D
#define BATIF_INT_RT_STS_REG			0x10
#define BATIF_SHIP_MODE_REG			0x52

/*USB reg address*/
#define USB_BASE				0x2900
#define USB_USBIN_INPUT_STATUS_REG		0x06
#define USB_VUSB_STATUS_REG			0x08
#define USB_APSD_STATUS_REG			0x0A
#define USB_APSD_RESULT_STATUS_REG		0x0B
#define USB_INT_RT_STS_REG			0x10
#define USB_USBIN_ADAPTER_ALLOW_CFG_REG		0x40
#define USB_USBIN_ADAPTER_ALLOW_OVERRIDE_REG	0x41
#define USB_APSD_EN_REG				0x44
#define USB_USB_ICL_CFG_REG			0x52
#define USB_USB_SUSPEND_REG			0x54

/*WLS reg address*/
#define WLS_BASE				0x2A00
#define WLS_INPUT_STATUS_REG			0x06
#define WLS_VWLS_STATUS_REG			0x08
#define WLS_INT_RT_STS				0x10
#define WLS_ADAPTER_ALLOW_CFG_REG		0x40
#define WLS_ICL_CFG_REG				0x52
#define WLS_SUSPEND_REG				0x54

/*TYPEC reg address*/
#define TYPEC_BASE				0x2B00
#define TYPEC_TYPE_C_SNK_STATUS_REG		0x06
#define TYPEC_TYPE_C_SNK_DBG_ACCESS_STATUS_REG	0x07
#define TYPEC_TYPE_C_SRC_STATUS_REG		0x08
#define TYPEC_TYPE_C_STATE_MACHINE_STATUS_REG	0x09
#define TYPEC_TYPE_C_MISC_STATUS_REG		0x0B
#define TYPEC_TYPE_C_TRY_SNK_SRC_STATUS_REG	0x0C
#define TYPEC_TYPE_C_LEGACY_CABLE_STATUS_REG	0x0D
#define TYPEC_INT_RT_STS_REG			0x10
#define TYPEC_TYPE_C_MODE_CFG_REG		0x44

/*MISC reg address*/
#define MISC_BASE				0x2C00
#define MISC_AICL_STATUS_REG			0x06
#define MISC_WDOG_STATUS_REG			0x07
#define MISC_SYSOK_REASON_STATUS_REG		0x0D
#define MISC_INT_RT_STS_REG			0x10
