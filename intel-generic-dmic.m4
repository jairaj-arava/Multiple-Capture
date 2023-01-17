#
# Topology for digital microphones array
#

include(`utils.m4')
include(`dai.m4')
include(`pipeline.m4')
include(`hda.m4')
include(`muxdemux.m4')

# # # Include TLV library
include(`common/tlv.m4')

# # # # Include Token library
include(`sof/tokens.m4')

# # # # Include bxt DSP configuration
include(`platform/intel/bxt.m4')

#include(`platform/intel/'PLATFORM`.m4')
# # # Include machine driver definitions
#include(`platform/intel/intel-boards.m4')


include(`platform/intel/dmic.m4')

# define default PCM names
ifdef(`DMIC_48k_PCM_NAME',`',
`define(DMIC_48k_PCM_NAME, `DMIC')')
ifdef(`DMIC_16k_PCM_NAME',`',
`define(DMIC_16k_PCM_NAME, `DMIC16kHz')')



define(DMIC_48k_PCM_1_NAME, `DMIC1')
define(DMIC_48k_PCM_2_NAME, `DMIC2')
define(DMIC_48k_PCM_3_NAME, `DMIC3')
define(DMIC_PCM_1_48k_ID, `101')
define(DMIC_PCM_2_48k_ID, `102')
define(DMIC_PCM_3_48k_ID, `103')

# variable that need to be defined in upper m4
ifdef(`DMICPROC',`',`fatal_error(note: Need to define dmic processing for intel-generic-dmic
)')
ifdef(`CHANNELS',`',`fatal_error(note: Need to define channel number for intel-generic-dmic
)')
ifdef(`DMIC_PIPELINE_48k_ID',`',`fatal_error(note: Need to define dmic48k pcm id for intel-generic-dmic
)')
ifdef(`DMIC_PIPELINE_48k_ID',`',`fatal_error(note: Need to define dmic48k pipeline id for intel-generic-dmic
)')
ifdef(`DMIC_DAI_LINK_48k_ID',`',`fatal_error(note: Need to define dmic48k dai id for intel-generic-dmic
)')

ifdef(`DMIC_PCM_16k_ID',`',`fatal_error(note: Need to define dmic16k pcm id for intel-generic-dmic
)')
ifdef(`DMIC_PIPELINE_16k_ID',`',`fatal_error(note: Need to define dmic16k pipeline id for intel-generic-dmic
)')
ifdef(`DMIC_DAI_LINK_16k_ID',`',`fatal_error(note: Need to define dmic16k dai id for intel-generic-dmic
)')

# define(DMIC_DAI_LINK_48k_NAME, `dmic01')
ifdef(`DMIC_DAI_LINK_48k_NAME',`',define(DMIC_DAI_LINK_48k_NAME, `dmic01'))

# define(DMIC_DAI_LINK_16k_NAME, `dmic16k')
ifdef(`DMIC_DAI_LINK_16k_NAME',`',define(DMIC_DAI_LINK_16k_NAME, `dmic16k'))

ifdef(`DMIC_48k_CORE_ID',`', define(DMIC_48k_CORE_ID, `0'))
ifdef(`DMIC_16k_CORE_ID',`', define(DMIC_16k_CORE_ID, `0'))

# Handle possible different channels count for PCM and DAI
ifdef(`DMIC_DAI_CHANNELS', `', `define(DMIC_DAI_CHANNELS, CHANNELS)')
ifdef(`DMIC_PCM_CHANNELS', `', `define(DMIC_PCM_CHANNELS, CHANNELS)')
ifdef(`DMIC16K_DAI_CHANNELS', `', `define(DMIC16K_DAI_CHANNELS, CHANNELS)')
ifdef(`DMIC16K_PCM_CHANNELS', `', `define(DMIC16K_PCM_CHANNELS, CHANNELS)')

dnl Unless explicitly specified, dmic period at 48k is 1ms
ifdef(`DMIC_48k_PERIOD_US', `', `define(DMIC_48k_PERIOD_US, 1000)')

define(`INTEL_GENERIC_DMIC_PERIOD', 1000)

ifelse(CHANNELS, 1, `define(`VOLUME_CHANNEL_MAP', LIST(`	', KCONTROL_CHANNEL(FL, 1, 0)))')
ifelse(CHANNELS, 2, `define(`VOLUME_CHANNEL_MAP', LIST(`	', KCONTROL_CHANNEL(FL, 1, 0),
							KCONTROL_CHANNEL(FR, 1, 1)))')
ifelse(CHANNELS, 3, `define(`VOLUME_CHANNEL_MAP', LIST(`	', KCONTROL_CHANNEL(FL, 1, 0),
							KCONTROL_CHANNEL(FC, 1, 1),
							KCONTROL_CHANNEL(FR, 1, 2)))')
ifelse(CHANNELS, 4, `define(`VOLUME_CHANNEL_MAP', LIST(`	', KCONTROL_CHANNEL(FLW, 1, 0),
							KCONTROL_CHANNEL(FL, 1, 1),
							KCONTROL_CHANNEL(FR, 1, 2),
							KCONTROL_CHANNEL(FRW, 1, 3)))')

ifelse(CHANNELS, 1, `define(`SWITCH_CHANNEL_MAP', LIST(`	', KCONTROL_CHANNEL(FL, 2, 0)))')
ifelse(CHANNELS, 2, `define(`SWITCH_CHANNEL_MAP', LIST(`	', KCONTROL_CHANNEL(FL, 2, 0),
							KCONTROL_CHANNEL(FR, 2, 1)))')
ifelse(CHANNELS, 3, `define(`SWITCH_CHANNEL_MAP', LIST(`	', KCONTROL_CHANNEL(FL, 2, 0),
							KCONTROL_CHANNEL(FC, 2, 1),
							KCONTROL_CHANNEL(FR, 2, 2)))')
ifelse(CHANNELS, 4, `define(`SWITCH_CHANNEL_MAP', LIST(`	', KCONTROL_CHANNEL(FLW, 2, 0),
							KCONTROL_CHANNEL(FL, 2, 1),
							KCONTROL_CHANNEL(FR, 2, 2),
							KCONTROL_CHANNEL(FRW, 2, 3)))')

#
# Define the demux configure
#
dnl Configure demux
dnl name, pipeline_id, routing_matrix_rows
dnl Diagonal 1's in routing matrix mean that every input channel is
dnl copied to corresponding output channels in all output streams.
dnl I.e. row index is the input channel, 1 means it is copied to
dnl corresponding output channel (column index), 0 means it is discarded.
dnl There's a separate matrix for all outputs.
define(matrix20, `ROUTE_MATRIX(20,
                             `BITS_TO_BYTE(1, 0, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 1, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 1 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,1 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,1 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,1 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,1 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,0 ,1)')')

define(matrix21, `ROUTE_MATRIX(21,
                             `BITS_TO_BYTE(1, 0, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 1, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 1 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,1 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,1 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,1 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,1 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,0 ,1)')')

define(matrix22, `ROUTE_MATRIX(22,
                             `BITS_TO_BYTE(1, 0, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 1, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 1 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,1 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,1 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,1 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,1 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,0 ,1)')')

define(matrix23, `ROUTE_MATRIX(23,
                             `BITS_TO_BYTE(1, 0, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 1, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 1 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,1 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,1 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,1 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,1 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,0 ,1)')')



# Passthrough capture pipeline using max channels defined by DMIC_PCM_CHANNELS.

# Set 1000us deadline with priority 0 on core 0
ifdef(`DMICPROC_FILTER1', `define(PIPELINE_FILTER1, DMICPROC_FILTER1)', `undefine(`PIPELINE_FILTER1')')
ifdef(`DMICPROC_FILTER2', `define(PIPELINE_FILTER2, DMICPROC_FILTER2)', `undefine(`PIPELINE_FILTER2')')
define(`PGA_NAME', Dmic0)


# capture DAI is DMIC 0 using 2 periods
# Buffers use s32le format, 1000us deadline with priority 0 on core 0
DAI_ADD(sof/pipe-dai-demux-capture.m4,
	10, DMIC, 0, DMIC_DAI_LINK_48k_NAME,
	NOT_USED_IGNORED, 2, s32le,
	DMIC_48k_PERIOD_US, 0, DMIC_48k_CORE_ID, SCHEDULE_TIME_DOMAIN_TIMER,
	2, 48000, 0)

undefine(`PGA_NAME')
undefine(`PIPELINE_FILTER1')
undefine(`PIPELINE_FILTER2')


PIPELINE_PCM_ADD(sof/pipe-passthrough-capture.m4,
	20, DMIC_PCM_1_48k_ID, DMIC_PCM_CHANNELS, s32le,
	DMIC_48k_PERIOD_US, 0, DMIC_48k_CORE_ID,
	48000, 48000, 48000,
	SCHEDULE_TIME_DOMAIN_TIMER, PIPELINE_DEMUX_CAPTURE_SCHED_COMP_10, 0)

PIPELINE_ADD(sof/pipe-volume-demux.m4,
	21, DMIC_PCM_CHANNELS, s32le,
	DMIC_48k_PERIOD_US, 0, DMIC_48k_CORE_ID,
	PIPELINE_DEMUX_CAPTURE_SCHED_COMP_10, SCHEDULE_TIME_DOMAIN_TIMER,
	 48000, 48000, 48000)

PIPELINE_PCM_ADD(sof/pipe-passthrough-capture.m4,
	22, DMIC_PCM_2_48k_ID, DMIC_PCM_CHANNELS, s32le,
	DMIC_48k_PERIOD_US, 0, DMIC_48k_CORE_ID, 
	48000, 48000, 48000,
	SCHEDULE_TIME_DOMAIN_TIMER, PIPELINE_DEMUX_CAPTURE_SCHED_COMP_10, 0)

PIPELINE_PCM_ADD(sof/pipe-volume-capture.m4,
	23, DMIC_PCM_3_48k_ID, DMIC_PCM_CHANNELS, s32le,
	DMIC_48k_PERIOD_US, 0, DMIC_48k_CORE_ID, 
	48000, 48000, 48000,
	SCHEDULE_TIME_DOMAIN_TIMER, PIPELINE_DEMUX_CAPTURE_SCHED_COMP_10, 0)


# Add pipeline widgets here to pipelines 11, 13, 34 to avoid modify
# # pipe-passthrough-capture.m4 and pipe-volume-capture.m4 with
# # W_PIPELINE() additions
W_PIPELINE_TOP(20, DMIC0.IN, DMIC_48k_PERIOD_US, 0, DMIC_48k_CORE_ID, 1, pipe_dai_schedule_plat)
W_PIPELINE_TOP(22, DMIC0.IN, DMIC_48k_PERIOD_US, 0, DMIC_48k_CORE_ID, 1, pipe_dai_schedule_plat)
W_PIPELINE_TOP(23, DMIC0.IN, DMIC_48k_PERIOD_US, 0, DMIC_48k_CORE_ID, 1, pipe_dai_schedule_plat)

dnl name, num_streams, route_matrix list
MUXDEMUX_CONFIG(demux_priv_10, 2, LIST_NONEWLINE(`', `matrix20,', `matrix21'))
MUXDEMUX_CONFIG(demux_priv_21, 2, LIST_NONEWLINE(`', `matrix22,', `matrix23'))

SectionGraph."dai-demux" {
	index "0"

	lines [
		# connect mixer dai pipelines to PCM pipelines
		dapm(PIPELINE_SINK_20, PIPELINE_DEMUX_SOURCE_10)
		dapm(PIPELINE_SINK_21, PIPELINE_DEMUX_SOURCE_10)
		dapm(PIPELINE_SINK_22, PIPELINE_DEMUX_SOURCE_21)
		dapm(PIPELINE_SINK_23, PIPELINE_DEMUX_SOURCE_21)
	]
}

# Passthrough capture pipeline using max channels defined by CHANNELS.

# Schedule with 1000us deadline with priority 0 on core 0
ifdef(`DMIC16KPROC_FILTER1', `define(PIPELINE_FILTER1, DMIC16KPROC_FILTER1)', `undefine(`PIPELINE_FILTER1')')
ifdef(`DMIC16KPROC_FILTER2', `define(PIPELINE_FILTER2, DMIC16KPROC_FILTER2)', `undefine(`PIPELINE_FILTER2')')
define(`PGA_NAME', Dmic1)

ifdef(NO16KDMIC, `',
`PIPELINE_PCM_ADD(sof/pipe-DMIC16KPROC-capture-16khz.m4,
	DMIC_PIPELINE_16k_ID, DMIC_PCM_16k_ID, DMIC16K_PCM_CHANNELS, s32le,
	INTEL_GENERIC_DMIC_PERIOD, 0, DMIC_16k_CORE_ID, 16000, 16000, 16000)')

undefine(`PGA_NAME')
undefine(`PIPELINE_FILTER1')
undefine(`PIPELINE_FILTER2')
undefine(`VOLUME_CHANNEL_MAP')
undefine(`SWITCH_CHANNEL_MAP')

#
# DAIs configuration
#

dnl DAI_ADD(pipeline,
dnl     pipe id, dai type, dai_index, dai_be,
dnl     buffer, periods, format,
dnl     deadline, priority, core, time_domain)

# capture DAI is DMIC 1 using 2 periods
# Buffers use s32le format, with 16 frame per 1000us on core 0 with priority 0
ifdef(NO16KDMIC, `',
`DAI_ADD(sof/pipe-dai-capture.m4,
	DMIC_PIPELINE_16k_ID, DMIC, 1, DMIC_DAI_LINK_16k_NAME,
	concat(`PIPELINE_SINK_', DMIC_PIPELINE_16k_ID), 2, s32le,
	INTEL_GENERIC_DMIC_PERIOD, 0, DMIC_16k_CORE_ID, SCHEDULE_TIME_DOMAIN_TIMER)')

dnl PCM_DUPLEX_ADD(name, pcm_id, playback, capture)
dnl PCM_CAPTURE_ADD(name, pipeline, capture)
PCM_CAPTURE_ADD(DMIC_48k_PCM_1_NAME, DMIC_PCM_1_48k_ID, PIPELINE_PCM_20)
PCM_CAPTURE_ADD(DMIC_48k_PCM_2_NAME, DMIC_PCM_2_48k_ID, PIPELINE_PCM_22)
PCM_CAPTURE_ADD(DMIC_48k_PCM_3_NAME, DMIC_PCM_3_48k_ID, PIPELINE_PCM_23)



ifdef(NO16KDMIC, `',
`PCM_CAPTURE_ADD(DMIC_16k_PCM_NAME, DMIC_PCM_16k_ID, concat(`PIPELINE_PCM_', DMIC_PIPELINE_16k_ID))')

#
# BE configurations - overrides config in ACPI if present
#

dnl DAI_CONFIG(type, dai_index, link_id, name, ssp_config/dmic_config)
ifelse(DMIC_DAI_CHANNELS, 4,
`DAI_CONFIG(DMIC, 0, DMIC_DAI_LINK_48k_ID, DMIC_DAI_LINK_48k_NAME,
	   DMIC_CONFIG(1, 2400000, 4800000, 40, 60, 48000,
		DMIC_WORD_LENGTH(s32le), 200, DMIC, 0,
		PDM_CONFIG(DMIC, 0, FOUR_CH_PDM0_PDM1)))',
`DAI_CONFIG(DMIC, 0, DMIC_DAI_LINK_48k_ID, DMIC_DAI_LINK_48k_NAME,
           DMIC_CONFIG(1, 2400000, 4800000, 40, 60, 48000,
                DMIC_WORD_LENGTH(s32le), 200, DMIC, 0,
                PDM_CONFIG(DMIC, 0, STEREO_PDM0)))')

ifdef(NO16KDMIC, `',
`ifelse(DMIC16K_DAI_CHANNELS, 4,
`DAI_CONFIG(DMIC, 1, DMIC_DAI_LINK_16k_ID, DMIC_DAI_LINK_16k_NAME,
	   DMIC_CONFIG(1, 2400000, 4800000, 40, 60, 16000,
		DMIC_WORD_LENGTH(s32le), 400, DMIC, 1,
		PDM_CONFIG(DMIC, 1, FOUR_CH_PDM0_PDM1)))',
`DAI_CONFIG(DMIC, 1, DMIC_DAI_LINK_16k_ID, DMIC_DAI_LINK_16k_NAME,
           DMIC_CONFIG(1, 2400000, 4800000, 40, 60, 16000,
                DMIC_WORD_LENGTH(s32le), 400, DMIC, 1,
                PDM_CONFIG(DMIC, 1, STEREO_PDM0)))')')
