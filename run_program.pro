;+
; FILENAME:
;    run_program.pro
; PURPOSE:
;    ----------
;    Run this file to get a complete comparison of different methods of Pansharpening.
;    The testing dataset is specifically designed to test the WorldView-2 dataset.
;    In order to run this program, a Multispectral (MS), Pansharpening (PAN), and
;    Groundtruth (GT) images are required. For testing purposes, Rio dataset (WorldView-2)
;    consisting of those three images is explored.
;    
; REMARK:
;    Every of these codes are made as closest as possible to its original Matlab version [Vivone14].
;    For further detail, please do refers to:
;    http://openremotesensing.net/knowledgebase/a-critical-comparison-among-pansharpening-algorithms/
;
; METHOD:
;       ENVI> RUN_PROGRAM
;
; REVISION HISTORY:
;    2019-Sept-30  H.Cahyono
;                  Initial coding.
;-

pro RUN_PROGRAM
  e = ENVI()

  ; base location of this project.
  BASE_PATH = 'C:\\Users\\HasanDC\\Documents\\IDLWorkspace\\Project 1\\'

  ; directory to save every processed file.
  PATH_TO_SAVE_AFILE = BASE_PATH + '\\processed\\'

  FLAG_CUT_BOUNDS = 1   ; a boundary cutting flag: 0 - not applied, 1 - applied (default).
  DIM_CUT = 11          ; the dimension of the boundary cutting. Mandatory if FLAG_CUT_BOUNDS = 1.
  RATIO = 4             ; a scale ratio (resize factor) of MS and PAN (ratio is in the power of 2).
  RESOLUTION = 11       ; radiometric resolution.
  NTERMS = 41           ; number of filters used in Modulation Transfer Function (MTF).
  NCOEFF = 11           ; number of coefficients used in the interpolation. Default: 23 coefficients (2x11)+1.
  MS_NYQ = 0.30         ; default Nyquist frequency for a MS is 0.30.
  PAN_NYQ = 0.30        ; default Nyquist frequency for a PAN is 0.30.

  ; Load a Low Resolution MS (MSLR - not yet tested), MS, PAN, and GT images.
  i_ms_lr = LOAD_TIF('Pich up a Low Resulution Multispectral Image')
  i_ms = LOAD_TIF('Pick up a Multispectral Image')
  i_pan_lr = LOAD_TIF('Pick up a Panchromatic Image')
  i_gt = LOAD_TIF('Pick up a Ground Truth Image')

  ; Nyquist frequency for every band in MS. Default: the same Nyquist value is assigned for each band.
  i_ms_t = i_ms
  ms_dim = SIZE(i_ms_t)
  if (ms_dim[0] gt 2 && ms_dim[3] gt 1) then MS_NYQ = [MS_NYQ*REPLICATE(1, ms_dim[3])]

  ; The non MSLR is set for the default MS since the MS has been processed.
  ; code is used.
  i_ms_sharpened = i_ms_t

  ; Default function when the MS has not been filtered and smoothed.
  ; i_ms_sharpened = RESIZE_IMAGE(i_ms_t, i_pan_lr, RATIO, MS_NYQ, PAN_NYQ, NTERMS, $
  ;   NCOEFF, UPSAMPLING_PAN=i_pan_resized)
  ; i_pan_lr = i_pan_resized

  ; The output images from four fusion algorithms are compared, namely: a combination of
  ; MTF and Generalized Laplacian Pyramid (MTF-GLP), high-pass filter (HPF),
  ; principal component analysis with and without an equalisation (PCA-EQ & PCA-NE).
  i_mtf_glp = MTF_GLP(i_ms_sharpened, i_pan_lr, PAN_NYQ, NTERMS, RATIO, /GLP, /FUSION)
  i_mtf_glp_eq = MTF_GLP(i_ms_sharpened, i_pan_lr, PAN_NYQ, NTERMS, RATIO, /GLP, /FUSION, /EQUALIZATION)
  i_hpf = HPF(i_ms_sharpened, i_pan_lr, RATIO, /FUSION)
  i_hpf_eq = HPF(i_ms_sharpened, i_pan_lr, RATIO, /FUSION, /EQUALIZATION)
  i_pca = PCA_FUS(i_ms_sharpened, i_pan_lr, /FUSION)
  i_pca_eq = PCA_FUS(i_ms_sharpened, i_pan_lr, /FUSION, /EQUALIZATION)

  ; Process only the replicated ground truth image while leaving the original remains.
  i_gt_r = i_gt

  ;;;;; Size Adjustment: adjust the size of GT with each of the prior fused images ;;;;;
  i_mtf_fused = SIZE_ADJUSTMENT(i_mtf_glp, GT_IMAGE=i_gt_r, RATIO, RESOLUTION, DIM_CUT, /CUT_BOUNDARY, /THRESHOLDING)
  i_mtf_fused_eq = SIZE_ADJUSTMENT(i_mtf_glp_eq, RATIO, RESOLUTION, DIM_CUT, /CUT_BOUNDARY, /THRESHOLDING)
  i_hpf_fused = SIZE_ADJUSTMENT(i_hpf, RATIO, RESOLUTION, DIM_CUT, /CUT_BOUNDARY, /THRESHOLDING)
  i_hpf_fused_eq = SIZE_ADJUSTMENT(i_hpf_eq, RATIO, RESOLUTION, DIM_CUT, /CUT_BOUNDARY, /THRESHOLDING)
  i_pca_fused = SIZE_ADJUSTMENT(i_pca, RATIO, RESOLUTION, DIM_CUT, /CUT_BOUNDARY, /THRESHOLDING)
  i_pca_fused_eq = SIZE_ADJUSTMENT(i_pca_eq, RATIO, RESOLUTION, DIM_CUT, /CUT_BOUNDARY, /THRESHOLDING)

  ;;;;; Performance Evaluation: Q-index, SAM, and ERGAS ;;;;;
  EVALUATION, i_gt_r, i_mtf_fused, RATIO, QINDEX=mtf_fused_q, $
    SAM_INDEX=mtf_fused_sam, ERGAS_INDEX=mtf_fused_ergas

  EVALUATION, i_gt_r, i_mtf_fused_eq, RATIO, QINDEX=mtf_fused_q_eq, $
    SAM_INDEX=mtf_fused_sam_eq, ERGAS_INDEX=mtf_fused_ergas_eq

  EVALUATION, i_gt_r, i_hpf_fused, RATIO, QINDEX=hpf_fused_q, $
    SAM_INDEX=hpf_fused_sam, ERGAS_INDEX=hpf_fused_ergas

  EVALUATION, i_gt_r, i_hpf_fused_eq, RATIO, QINDEX=hpf_fused_q_eq, $
    SAM_INDEX=hpf_fused_sam_eq, ERGAS_INDEX=hpf_fused_ergas_eq

  EVALUATION, i_gt_r, i_pca_fused, RATIO, QINDEX=pca_fused_q, $
    SAM_INDEX=pca_fused_sam, ERGAS_INDEX=pca_fused_ergas

  EVALUATION, i_gt_r, i_pca_fused_eq, RATIO, QINDEX=pca_fused_q_eq, $
    SAM_INDEX=pca_fused_sam_eq, ERGAS_INDEX=pca_fused_ergas_eq

  ;;;;; Save the necessary data ;;;;;
  ; The data of all images are saved into a SAV file (data.sav).
  SAVE, FILENAME = PATH_TO_SAVE_AFILE + 'data.sav', $
    i_ms_sharpened, i_ms, i_ms_lr, $
    i_pan_lr, i_gt, i_gt_r, i_mtf_fused, i_mtf_fused_eq, $
    i_hpf_fused, i_hpf_fused_eq, i_pca_fused, i_pca_fused_eq

  ; The quality assessment results are also saved into a SAV file (quality.sav).
  SAVE, FILENAME = PATH_TO_SAVE_AFILE + 'quality.sav', $
    mtf_fused_q, mtf_fused_sam, mtf_fused_ergas, $
    mtf_fused_q_eq, mtf_fused_sam_eq, mtf_fused_ergas_eq, $
    hpf_fused_q, hpf_fused_sam, hpf_fused_ergas, $
    hpf_fused_q_eq, hpf_fused_sam_eq, hpf_fused_ergas_eq, $
    pca_fused_q, pca_fused_sam, pca_fused_ergas, $
    pca_fused_q_eq, pca_fused_sam_eq, pca_fused_ergas_eq

  ;;;;; load the necessary images into ENVI environment. ;;;;;
  ENVI_ENTER_DATA, i_ms_sharpened     ; MS reference.

  ; the fused images in theirs original sizes.
  ENVI_ENTER_DATA, i_mtf_glp          ; MTF-GLP fused image.
  ENVI_ENTER_DATA, i_mtf_glp_eq       ; MTF-GLP fused image.
  ENVI_ENTER_DATA, i_hpf              ; HPF fused image.
  ENVI_ENTER_DATA, i_hpf_eq           ; HPF fused image.
  ENVI_ENTER_DATA, i_pca              ; PCA-NE image.
  ENVI_ENTER_DATA, i_pca_eq           ; PCA-EQ image.

  ; the size adjusted images.
  ENVI_ENTER_DATA, i_mtf_fused        ; MTF-GLP image.
  ENVI_ENTER_DATA, i_mtf_fused_eq     ; MTF-GLP_eq image.
  ENVI_ENTER_DATA, i_hpf_fused        ; HPF image.
  ENVI_ENTER_DATA, i_hpf_fused_eq     ; HPF image.
  ENVI_ENTER_DATA, i_pca_fused        ; PCA-NE image.
  ENVI_ENTER_DATA, i_pca_fused_eq     ; PCA-EQ image.
end
