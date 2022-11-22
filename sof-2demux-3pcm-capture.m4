# Include topology builder
include(`utils.m4')
include(`dai.m4')
include(`pipeline.m4')
include(`hda.m4')
include(`muxdemux.m4')

# # # Include TLV library
include(`common/tlv.m4')

# # # Include Token library
include(`sof/tokens.m4')

# # # Include bxt DSP configuration
include(`platform/intel/bxt.m4')

# # # Intel DMIC
include(`platform/intel/dmic.m4')
include(`platform/intel/'PLATFORM`.m4')
# # Include machine driver definitions
include(`platform/intel/intel-boards.m4')

# #
# # Topology for digital microphones array
# #

DEBUG_START


define(DMIC_PCM_CHANNELS, `2')
define(DMIC_48k_PCM_1_NAME, `Passthrough Capture 6')
define(DMIC_48k_PCM_2_NAME, `Passthrough Capture 7')
define(DMIC_48k_PCM_3_NAME, `Passthrough Capture 8')
define(DMIC_PCM_1_48k_ID, `6')
define(DMIC_PCM_2_48k_ID, `7')
define(DMIC_PCM_3_48k_ID, `8')
define(DMIC_DAI_LINK_48k_ID, `1')
define(DMIC_DAI_LINK_48k_NAME, `dmic01')
define(DMIC_48k_PERIOD_US, `1000')
define(DMIC_48k_CORE_ID, `0')
define(DEF_STEREO_PDM, `STEREO_PDM0')

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
define(matrix11, `ROUTE_MATRIX(11,
                             `BITS_TO_BYTE(1, 0, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 1, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 1 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,1 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,1 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,1 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,1 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,0 ,1)')')

define(matrix12, `ROUTE_MATRIX(12,
                             `BITS_TO_BYTE(1, 0, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 1, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 1 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,1 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,1 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,1 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,1 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,0 ,1)')')

define(matrix13, `ROUTE_MATRIX(13,
                             `BITS_TO_BYTE(1, 0, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 1, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 1 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,1 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,1 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,1 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,1 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,0 ,1)')')

define(matrix14, `ROUTE_MATRIX(14,
                             `BITS_TO_BYTE(1, 0, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 1, 0 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 1 ,0 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,1 ,0 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,1 ,0 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,1 ,0 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,1 ,0)',
                             `BITS_TO_BYTE(0, 0, 0 ,0 ,0 ,0 ,0 ,1)')')


dnl DAI_ADD(pipeline,
dnl     pipe id, dai type, dai_index, dai_be,
dnl     buffer, periods, format,
dnl     period , priority, core, time_domain,
dnl     channels, rate, dynamic_pipe)
DAI_ADD(sof/pipe-dai-demux-capture.m4,
        10, DMIC, 0, DMIC_DAI_LINK_48k_NAME,
        NOT_USED_IGNORED, 2, s32le,
        1000, 0, DMIC_48k_CORE_ID, SCHEDULE_TIME_DOMAIN_TIMER,
	2, 48000, 0)

# RAW DAI capture pipeline

dnl PIPELINE_PCM_ADD(pipeline,
dnl     pipe id, pcm, max channels, format,
dnl     period, priority, core,
dnl     pcm_min_rate, pcm_max_rate, pipeline_rate,
dnl     time_domain, sched_comp, dynamic)
PIPELINE_PCM_ADD(sof/pipe-passthrough-capture.m4,
	11, DMIC_PCM_1_48k_ID, 2, s32le,
	DMIC_48k_PERIOD_US, 0, DMIC_48k_CORE_ID,
	48000, 48000, 48000,
	SCHEDULE_TIME_DOMAIN_TIMER, PIPELINE_DEMUX_CAPTURE_SCHED_COMP_10, 0)


# Intermediate processing1-demux pipeline
# Check: PIPELINE_ADD arg 13 DYNAMIC_PIPE errors -- omit now

dnl PIPELINE_ADD(pipeline,
dnl     pipe id, max channels, format,
dnl     period, priority, core,
dnl     sched_comp, time_domain,
dnl     pcm_min_rate, pcm_max_rate, pipeline_rate, dynamic)
PIPELINE_ADD(sof/pipe-volume-demux.m4,
	12, 2, s32le,
	DMIC_48k_PERIOD_US, 0, DMIC_48k_CORE_ID,
	PIPELINE_DEMUX_CAPTURE_SCHED_COMP_10, SCHEDULE_TIME_DOMAIN_TIMER,
	48000, 48000, 48000)

# Capture PCM pipeline from processing1

dnl PIPELINE_PCM_ADD(pipeline,
dnl     pipe id, pcm, max channels, format,
dnl     period, priority, core,
dnl     pcm_min_rate, pcm_max_rate, pipeline_rate,
dnl     time_domain, sched_comp, dynamic)
PIPELINE_PCM_ADD(sof/pipe-passthrough-capture.m4,
	13, DMIC_PCM_2_48k_ID, DMIC_PCM_CHANNELS, s32le,
	DMIC_48k_PERIOD_US, 0, DMIC_48k_CORE_ID,
	48000, 48000, 48000,
	SCHEDULE_TIME_DOMAIN_TIMER, PIPELINE_DEMUX_CAPTURE_SCHED_COMP_10, 0)

# Capture PCM pipeline with processing2

dnl PIPELINE_PCM_ADD(pipeline,
dnl     pipe id, pcm, max channels, format,
dnl     period, priority, core,
dnl     pcm_min_rate, pcm_max_rate, pipeline_rate,
dnl     time_domain, sched_comp, dynamic)
PIPELINE_PCM_ADD(sof/pipe-volume-capture.m4,
	14, DMIC_PCM_3_48k_ID, DMIC_PCM_CHANNELS, s32le,
	DMIC_48k_PERIOD_US, 0, DMIC_48k_CORE_ID,
	48000, 48000, 48000,
	SCHEDULE_TIME_DOMAIN_TIMER, PIPELINE_DEMUX_CAPTURE_SCHED_COMP_10, 0)


dnl name, num_streams, route_matrix list
MUXDEMUX_CONFIG(demux_priv_10, 2, LIST_NONEWLINE(`', `matrix11,', `matrix12'))
MUXDEMUX_CONFIG(demux_priv_12, 2, LIST_NONEWLINE(`', `matrix13,', `matrix14'))

SectionGraph."dai-demux" {
	index "0"

	lines [
		# connect mixer dai pipelines to PCM pipelines
		dapm(PIPELINE_SINK_11, PIPELINE_DEMUX_SOURCE_10)
		dapm(PIPELINE_SINK_12, PIPELINE_DEMUX_SOURCE_10)
		dapm(PIPELINE_SINK_13, PIPELINE_DEMUX_SOURCE_12)
		dapm(PIPELINE_SINK_14, PIPELINE_DEMUX_SOURCE_12)
	]
}

dnl PCM_DUPLEX_ADD(name, pcm_id, playback, capture)
dnl PCM_CAPTURE_ADD(name, pipeline, capture)
PCM_CAPTURE_ADD(DMIC_48k_PCM_1_NAME, DMIC_PCM_1_48k_ID, PIPELINE_PCM_11)
PCM_CAPTURE_ADD(DMIC_48k_PCM_2_NAME, DMIC_PCM_2_48k_ID, PIPELINE_PCM_13)
PCM_CAPTURE_ADD(DMIC_48k_PCM_3_NAME, DMIC_PCM_3_48k_ID, PIPELINE_PCM_14)

dnl DAI_CONFIG(type, dai_index, link_id, name, ssp_config/dmic_config)
DAI_CONFIG(DMIC, 0, DMIC_DAI_LINK_48k_ID, DMIC_DAI_LINK_48k_NAME,
           DMIC_CONFIG(1, 2400000, 4800000, 40, 60, 48000,
    	               DMIC_WORD_LENGTH(s32le), 200, DMIC, 0,
           	       PDM_CONFIG(DMIC, 0, DEF_STEREO_PDM)))

DEBUG_END
