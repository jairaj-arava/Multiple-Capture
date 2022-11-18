# Include topology builder
include(`utils.m4')
include(`dai.m4')
include(`pipeline.m4')
include(`hda.m4')
include(`muxdemux.m4')
#
# # Include TLV library
include(`common/tlv.m4')
#
# # Include Token library
include(`sof/tokens.m4')
#
# # Include bxt DSP configuration
include(`platform/intel/bxt.m4')
#
# # Intel DMIC
include(`platform/intel/dmic.m4')

include(`platform/intel/'PLATFORM`.m4')
# Include machine driver definitions
include(`platform/intel/intel-boards.m4')

#
# Topology for digital microphones array
#

DEBUG_START

define(DMIC_PCM_CHANNELS, `2')
define(DMIC_48k_PCM_1_NAME, `Passthrough Capture 6')
define(DMIC_48k_PCM_2_NAME, `Passthrough Capture 7')
define(DMIC_48k_PCM_3_NAME, `Passthrough Capture 8')
define(DMIC_PCM_1_48k_ID, `6')
define(DMIC_PCM_2_48k_ID, `7')
define(DMIC_PCM_3_48k_ID, `8')
define(DMIC_DAI_LINK_48k_ID, `1')
define(DMIC_PIPELINE_1_48k_ID, `52')
define(DMIC_PIPELINE_2_48k_ID, `53')
define(DMIC_PIPELINE_3_48k_ID, `54')
define(DMIC_48k_PERIOD_US, `1000')
define(DMIC_48k_CORE_ID, `0')
define(DMIC_DAI_LINK_48k_NAME, `dmic01')
define(DEF_STEREO_PDM, `STEREO_PDM0')



define(matrix1, `ROUTE_MATRIX(52,
                             `BITS_TO_BYTE(1, 0, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 1, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 1 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,1 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,1 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,1 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,1 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,0 ,1)')')

define(matrix2, `ROUTE_MATRIX(53,
                             `BITS_TO_BYTE(1, 0, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 1, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 1 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,1 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,1 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,1 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,1 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,0 ,1)')')

define(matrix3, `ROUTE_MATRIX(54,
                             `BITS_TO_BYTE(1, 0, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 1, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 1 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,1 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,1 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,1 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,1 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,0 ,1)')')


DAI_ADD(sof/pipe-dai-demux-capture.m4,
        13, DMIC, 0, DMIC_DAI_LINK_48k_NAME,
        NOT_USED_IGNORED, 2, s32le,
        1000, 0, DMIC_48k_CORE_ID, SCHEDULE_TIME_DOMAIN_TIMER, 2, 48000)

PIPELINE_PCM_ADD(sof/pipe-volume-capture.m4,
	DMIC_PIPELINE_1_48k_ID, DMIC_PCM_1_48k_ID, DMIC_PCM_CHANNELS, s32le,
	DMIC_48k_PERIOD_US, 0, DMIC_48k_CORE_ID, 48000, 48000, 48000,
	SCHEDULE_TIME_DOMAIN_TIMER, PIPELINE_DEMUX_CAPTURE_SCHED_COMP_13)

PIPELINE_PCM_ADD(sof/pipe-volume-capture.m4,
	DMIC_PIPELINE_2_48k_ID, DMIC_PCM_2_48k_ID, DMIC_PCM_CHANNELS, s32le,
	DMIC_48k_PERIOD_US, 0, DMIC_48k_CORE_ID, 48000, 48000, 48000,
	SCHEDULE_TIME_DOMAIN_TIMER, PIPELINE_DEMUX_CAPTURE_SCHED_COMP_13)

PIPELINE_PCM_ADD(sof/pipe-volume-capture.m4,
	DMIC_PIPELINE_3_48k_ID, DMIC_PCM_3_48k_ID, DMIC_PCM_CHANNELS, s32le,
	DMIC_48k_PERIOD_US, 0, DMIC_48k_CORE_ID, 48000, 48000, 48000,
	SCHEDULE_TIME_DOMAIN_TIMER, PIPELINE_DEMUX_CAPTURE_SCHED_COMP_13)

MUXDEMUX_CONFIG(demux_priv_13, 3, LIST_NONEWLINE(`', `matrix1,', `matrix2,', `matrix3'))

SectionGraph."dai-demux" {
	index "0"

	lines [

		dapm(PIPELINE_SINK_52, PIPELINE_DEMUX_SOURCE_13)
		dapm(PIPELINE_SINK_53, PIPELINE_DEMUX_SOURCE_13)
		dapm(PIPELINE_SINK_54, PIPELINE_DEMUX_SOURCE_13)
	]
}


dnl PCM_CAPTURE_ADD(name, pipeline, capture)

PCM_CAPTURE_ADD(DMIC_48k_PCM_1_NAME, DMIC_PCM_1_48k_ID, concat(`PIPELINE_PCM_', DMIC_PIPELINE_1_48k_ID))
PCM_CAPTURE_ADD(DMIC_48k_PCM_2_NAME, DMIC_PCM_2_48k_ID, concat(`PIPELINE_PCM_', DMIC_PIPELINE_2_48k_ID))
PCM_CAPTURE_ADD(DMIC_48k_PCM_3_NAME, DMIC_PCM_3_48k_ID, concat(`PIPELINE_PCM_', DMIC_PIPELINE_3_48k_ID))


dnl DAI_CONFIG(type, dai_index, link_id, name, ssp_config/dmic_config)

DAI_CONFIG(DMIC, 0, DMIC_DAI_LINK_48k_ID, DMIC_DAI_LINK_48k_NAME,
           DMIC_CONFIG(1, 2400000, 4800000, 40, 60, 48000,
    	               DMIC_WORD_LENGTH(s32le), 200, DMIC, 0,
			PDM_CONFIG(DMIC, 0, DEF_STEREO_PDM)))

DEBUG_END
