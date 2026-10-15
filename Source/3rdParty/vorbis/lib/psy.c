/********************************************************************
 *                                                                  *
 * THIS FILE IS PART OF THE OggVorbis SOFTWARE CODEC SOURCE CODE.   *
 * USE, DISTRIBUTION AND REPRODUCTION OF THIS LIBRARY SOURCE IS     *
 * GOVERNED BY A BSD-STYLE SOURCE LICENSE INCLUDED WITH THIS SOURCE *
 * IN 'COPYING'. PLEASE READ THESE TERMS BEFORE DISTRIBUTING.       *
 *                                                                  *
 * THE OggVorbis SOURCE CODE IS (C) COPYRIGHT 1994-2010             *
 * by the Xiph.Org Foundation https://xiph.org/                     *
 *                                                                  *
 ********************************************************************

 function: psychoacoustics not including preecho

 ********************************************************************/

#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "vorbis/codec.h"
#include "codec_internal.h"
#ifdef __SSE__												/* SSE Optimize */
#include "xmmlib.h"
#endif														/* SSE Optimize */

#include "masking.h"
#include "psy.h"
#include "os.h"
#include "lpc.h"
#include "smallft.h"
#include "scales.h"
#include "misc.h"

#define NEGINF -9999.f

#define existe(x,y) (x<-y || x>=y) // !existe(x,0.5f) is faster than (rint(x)==0.f). (By the same result)
#define refer_phase(a,b) ((a>0. && b<0.) || (b>0. && a<0.))

#define M3C 3
                                           /*  0    1    2    3    4    5    6    7    8  */
static const double stereo_threshholds[]=    {0.0, 0.5, 1.0, 1.5, 2.5, 4.5, 8.5,16.5, 9e10};
static const double stereo_threshholds_X[]=  {0.0, 0.5, 0.5, 0.5, 0.5, 1.5, 4.0, 6.0, 9e10};

static const int m3n32[M3C] = {13,10,4};
static const int m3n44[M3C] = {9,7,3}; // 1550.390625, 1205.859375, 516.796875
static const int m3n48[M3C] = {8,6,3};
static const int m3n32x2[M3C] = {26,20,8};
static const int m3n44x2[M3C] = {18,14,6};
static const int m3n48x2[M3C] = {16,12,6};

static const int freq_bfn128[128] = {
 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3,
 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7,
 8, 8, 8, 8, 9, 9, 9, 9,10,10,10,10,11,11,11,11,
12,12,12,12,13,13,13,13,14,14,14,14,15,15,15,15,

16,16,16,16,17,17,17,17,18,18,18,18,19,19,19,19,
20,20,20,20,21,21,21,21,22,22,22,22,23,23,23,23,
24,24,24,24,25,25,25,24,23,22,21,20,19,18,17,16,
15,14,13,12,11,10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 1,
};
static const int freq_bfn256[256] = {
 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3,
 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7,
 8, 8, 8, 8, 9, 9, 9, 9,10,10,10,10,11,11,11,11,
12,12,12,12,13,13,13,13,14,14,14,14,15,15,15,15,
16,16,16,16,17,17,17,17,18,18,18,18,19,19,19,19,
20,20,20,20,21,21,21,21,22,22,22,22,23,23,23,23,
24,24,24,24,25,25,25,25,26,26,26,26,27,27,27,27,
28,28,28,28,29,29,29,29,30,30,30,30,31,31,31,31,

32,32,32,32,33,33,33,33,34,34,34,34,35,35,35,35,
36,36,36,36,37,37,37,37,38,38,38,38,39,39,39,39,
40,40,40,40,41,41,41,41,42,42,42,42,43,43,43,43,
44,44,44,44,45,45,45,45,46,46,46,46,47,47,47,47,
48,48,48,48,49,49,49,49,50,50,50,50,51,50,49,48,
47,46,45,44,43,42,41,40,39,38,37,36,35,34,33,32,
31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,
15,14,13,12,11,10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 1,
};

/* noise compander for stereo threshlod calc. */
static const int stn_compand[]={
     0, 1, 2, 3, 4, 5, 6,  7,
     8, 9,10,10,11,11,12, 12,
    13,13,14,14,15,15,15, 16,
    16,16,17,17,18,18,18, 19,
    19,19,20,21,22,23,24, 25,
};

static const float ntfix_offset[]={
/*  63     125     250     500      1k      2k      4k      8k     16k*/
    0,  0,  0,  0,  4,  8, 10, 16, 24, 30, 30, 30, 20, 14,  5,  1,  0};

static const aotuv_preset set_aotuv_psy[12]={
/* tc_end tc_th min_lp tonefix */
  {  124, .9f,   120,     104}, // 32 short(N=128)
  {  248, .9f,   240,     208}, // 32 short(N=256)
  {  992, .9f,   960,     832}, // 32 long(N=1024)
  { 1984, .9f,  1920,    1664}, // 32 long(N=2048)

  {   83, .9f,    80,      70}, // 48 short(N=128)
  {  166, .9f,   160,     140}, // 48 short(N=256)
  {  664, .9f,   640,     560}, // 48 long(N=1024)
  { 1328, .9f,  1280,    1120}, // 48 long(N=2048)

  {   90, .9f,    87,      76}, // 44.1 short(N=128)
  {  180, .9f,   174,     152}, // 44.1 short(N=256)
  {  720, .9f,   696,     608}, // 44.1 long(N=1024)  13953.515625
  { 1440, .9f,  1392,    1216}  // 44.1 long(N=2048)
};

#ifdef __SSE__												/* SSE Optimize */
static _MM_ALIGN16 const float PNEGINF[4] = {NEGINF, NEGINF, NEGINF, NEGINF};

_MM_ALIGN16 float findex[2048];
_MM_ALIGN16 float findex2[2048];

#endif														/* SSE Optimize */

vorbis_look_psy_global *_vp_global_look(vorbis_info *vi){
  codec_setup_info *ci=vi->codec_setup;
  vorbis_info_psy_global *gi=&ci->psy_g_param;
  vorbis_look_psy_global *look=_ogg_calloc(1,sizeof(*look));

  look->channels=vi->channels;

  look->ampmax=-9999.;
  look->gi=gi;
  return(look);
}

void _vp_global_free(vorbis_look_psy_global *look){
  if(look){
    memset(look,0,sizeof(*look));
    _ogg_free(look);
  }
}

void _vi_gpsy_free(vorbis_info_psy_global *i){
  if(i){
    memset(i,0,sizeof(*i));
    _ogg_free(i);
  }
}

void _vi_psy_free(vorbis_info_psy *i){
  if(i){
    memset(i,0,sizeof(*i));
    _ogg_free(i);
  }
}

static void min_curve(float *c,
                       float *c2){
  int i;
  for(i=0;i<EHMER_MAX;i++)if(c2[i]<c[i])c[i]=c2[i];
}
static void max_curve(float *c,
                       float *c2){
  int i;
  for(i=0;i<EHMER_MAX;i++)if(c2[i]>c[i])c[i]=c2[i];
}

static void attenuate_curve(float *c,float att){
  int i;
  for(i=0;i<EHMER_MAX;i++)
    c[i]+=att;
}

static float ***setup_tone_curves(float curveatt_dB[P_BANDS],float binHz,int n,
                                  float center_boost, float center_decay_rate){
  int i,j,k,m;
  float ath[EHMER_MAX];
  float workc[P_BANDS][P_LEVELS][EHMER_MAX];
  float athc[P_LEVELS][EHMER_MAX];
  float *brute_buffer=alloca(n*sizeof(*brute_buffer));

  float ***ret=_ogg_malloc(sizeof(*ret)*P_BANDS);

  memset(workc,0,sizeof(workc));

  for(i=0;i<P_BANDS;i++){
    /* we add back in the ATH to avoid low level curves falling off to
       -infinity and unnecessarily cutting off high level curves in the
       curve limiting (last step). */

    /* A half-band's settings must be valid over the whole band, and
       it's better to mask too little than too much */
    int ath_offset=i*4;
    for(j=0;j<EHMER_MAX;j++){
      float min=999.;
      for(k=0;k<4;k++)
        if(j+k+ath_offset<MAX_ATH){
          if(min>ATH[j+k+ath_offset])min=ATH[j+k+ath_offset];
        }else{
          if(min>ATH[MAX_ATH-1])min=ATH[MAX_ATH-1];
        }
      ath[j]=min;
    }

    /* copy curves into working space, replicate the 50dB curve to 30
       and 40, replicate the 100dB curve to 110 */
    for(j=0;j<6;j++)
      memcpy(workc[i][j+2],tonemasks[i][j],EHMER_MAX*sizeof(*tonemasks[i][j]));
    memcpy(workc[i][0],tonemasks[i][0],EHMER_MAX*sizeof(*tonemasks[i][0]));
    memcpy(workc[i][1],tonemasks[i][0],EHMER_MAX*sizeof(*tonemasks[i][0]));

    /* apply centered curve boost/decay */
    for(j=0;j<P_LEVELS;j++){
      for(k=0;k<EHMER_MAX;k++){
        float adj=center_boost+abs(EHMER_OFFSET-k)*center_decay_rate;
        if(adj<0. && center_boost>0)adj=0.;
        if(adj>0. && center_boost<0)adj=0.;
        workc[i][j][k]+=adj;
      }
    }

    /* normalize curves so the driving amplitude is 0dB */
    /* make temp curves with the ATH overlayed */
    for(j=0;j<P_LEVELS;j++){
      attenuate_curve(workc[i][j],curveatt_dB[i]+100.-(j<2?2:j)*10.-P_LEVEL_0);
      memcpy(athc[j],ath,EHMER_MAX*sizeof(**athc));
      attenuate_curve(athc[j],+100.-j*10.f-P_LEVEL_0);
      max_curve(athc[j],workc[i][j]);
    }

    /* Now limit the louder curves.

       the idea is this: We don't know what the playback attenuation
       will be; 0dB SL moves every time the user twiddles the volume
       knob. So that means we have to use a single 'most pessimal' curve
       for all masking amplitudes, right?  Wrong.  The *loudest* sound
       can be in (we assume) a range of ...+100dB] SL.  However, sounds
       20dB down will be in a range ...+80], 40dB down is from ...+60],
       etc... */

    for(j=1;j<P_LEVELS;j++){
      min_curve(athc[j],athc[j-1]);
      min_curve(workc[i][j],athc[j]);
    }
  }

  for(i=0;i<P_BANDS;i++){
    int hi_curve,lo_curve,bin;
    ret[i]=_ogg_malloc(sizeof(**ret)*P_LEVELS);

    /* low frequency curves are measured with greater resolution than
       the MDCT/FFT will actually give us; we want the curve applied
       to the tone data to be pessimistic and thus apply the minimum
       masking possible for a given bin.  That means that a single bin
       could span more than one octave and that the curve will be a
       composite of multiple octaves.  It also may mean that a single
       bin may span > an eighth of an octave and that the eighth
       octave values may also be composited. */

    /* which octave curves will we be compositing? */
    bin=floor(fromOC(i*.5)/binHz);
    lo_curve=  ceil(toOC(bin*binHz+1)*2);
    hi_curve=  floor(toOC((bin+1)*binHz)*2);
    if(lo_curve>i)lo_curve=i;
    if(lo_curve<0)lo_curve=0;
    if(hi_curve>=P_BANDS)hi_curve=P_BANDS-1;

    for(m=0;m<P_LEVELS;m++){
      ret[i][m]=_ogg_malloc(sizeof(***ret)*(EHMER_MAX+2));

      for(j=0;j<n;j++)brute_buffer[j]=999.;

      /* render the curve into bins, then pull values back into curve.
         The point is that any inherent subsampling aliasing results in
         a safe minimum */
      for(k=lo_curve;k<=hi_curve;k++){
        int l=0;

        for(j=0;j<EHMER_MAX;j++){
          int lo_bin= fromOC(j*.125+k*.5-2.0625)/binHz;
          int hi_bin= fromOC(j*.125+k*.5-1.9375)/binHz+1;

          if(lo_bin<0)lo_bin=0;
          if(lo_bin>n)lo_bin=n;
          if(lo_bin<l)l=lo_bin;
          if(hi_bin<0)hi_bin=0;
          if(hi_bin>n)hi_bin=n;

          for(;l<hi_bin && l<n;l++)
            if(brute_buffer[l]>workc[k][m][j])
              brute_buffer[l]=workc[k][m][j];
        }

        for(;l<n;l++)
          if(brute_buffer[l]>workc[k][m][EHMER_MAX-1])
            brute_buffer[l]=workc[k][m][EHMER_MAX-1];

      }

      /* be equally paranoid about being valid up to next half ocatve */
      if(i+1<P_BANDS){
        int l=0;
        k=i+1;
        for(j=0;j<EHMER_MAX;j++){
          int lo_bin= fromOC(j*.125+i*.5-2.0625)/binHz;
          int hi_bin= fromOC(j*.125+i*.5-1.9375)/binHz+1;

          if(lo_bin<0)lo_bin=0;
          if(lo_bin>n)lo_bin=n;
          if(lo_bin<l)l=lo_bin;
          if(hi_bin<0)hi_bin=0;
          if(hi_bin>n)hi_bin=n;

          for(;l<hi_bin && l<n;l++)
            if(brute_buffer[l]>workc[k][m][j])
              brute_buffer[l]=workc[k][m][j];
        }

        for(;l<n;l++)
          if(brute_buffer[l]>workc[k][m][EHMER_MAX-1])
            brute_buffer[l]=workc[k][m][EHMER_MAX-1];

      }


      for(j=0;j<EHMER_MAX;j++){
        int bin=fromOC(j*.125+i*.5-2.)/binHz;
        if(bin<0){
          ret[i][m][j+2]=-999.;
        }else{
          if(bin>=n){
            ret[i][m][j+2]=-999.;
          }else{
            ret[i][m][j+2]=brute_buffer[bin];
          }
        }
      }

      /* add fenceposts */
      for(j=0;j<EHMER_OFFSET;j++)
        if(ret[i][m][j+2]>-200.f)break;
      ret[i][m][0]=j;

      for(j=EHMER_MAX-1;j>EHMER_OFFSET+1;j--)
        if(ret[i][m][j+2]>-200.f)
          break;
      ret[i][m][1]=j;

    }
  }

  return(ret);
}

void _vp_psy_init(vorbis_look_psy *p,vorbis_info_psy *vi,
                  vorbis_info_psy_global *gi,int n,long rate){
  long i,j,lo=-99,hi=1;
  long maxoc, select=-1;
  memset(p,0,sizeof(*p));

  p->eighth_octave_lines=gi->eighth_octave_lines;
  p->shiftoc=rint(log(gi->eighth_octave_lines*8.f)/log(2.f))-1;

  p->firstoc=toOC(.25f*rate*.5/n)*(1<<(p->shiftoc+1))-gi->eighth_octave_lines;
  maxoc=toOC((n+.25f)*rate*.5/n)*(1<<(p->shiftoc+1))+.5f;
  p->total_octave_lines=maxoc-p->firstoc+1;
  p->ath=_ogg_malloc(n*sizeof(*p->ath));

  p->octave=_ogg_malloc(n*sizeof(*p->octave));
  p->bark=_ogg_malloc(n*sizeof(*p->bark));
  p->vi=vi;
  p->n=n;
  p->rate=rate;

  /* AoTuV HF weighting etc. */
  p->n25p=n/4;
  p->n33p=n/3;
  p->n75p=p->n25p*3;
  p->nn25pt=vi->normal_partition/4;
  p->nn50pt=p->nn25pt+p->nn25pt;
  p->nn75pt=p->nn25pt*3;

  if(rate < 26000){
    /* below 26kHz */
    p->m_val = 0;
    select=-1;
    for(i=0; i<M3C; i++) p->m3n[i] = 0;
  }else if(rate < 38000){
    /* 32kHz */
    p->m_val = .93;
    if(n==128){
      select=0;
      for(i=0; i<M3C; i++) p->m3n[i] = m3n32[i];
    }else if(n==256){
      select=1;
      for(i=0; i<M3C; i++) p->m3n[i] = m3n32x2[i];
    }else if(n==1024){
      select=2;
    }else if(n==2048){
      select=3;
    }
  }else if(rate > 46000){
    /* 48kHz */
    p->m_val = 1.205;
    if(n==128){
      select=4;
      for(i=0; i<M3C; i++) p->m3n[i] = m3n48[i];
    }else if(n==256){
      select=5;
      for(i=0; i<M3C; i++) p->m3n[i] = m3n48x2[i];
    }else if(n==1024){
      select=6;
    }else if(n==2048){
      select=7;
    }
  }else{
    /* 44.1kHz */
    p->m_val = 1.;
    if(n==128){
      select=8;
      for(i=0; i<M3C; i++) p->m3n[i] = m3n44[i];
    }else if(n==256){
      select=9;
      for(i=0; i<M3C; i++) p->m3n[i] = m3n44x2[i];
    }else if(n==1024){
      select=10;
    }else if(n==2048){
      select=11;
    }
  }

  if(select<0){
    p->tonecomp_endp=0; // dummy
    p->tonecomp_thres=.25;
    p->min_nn_lp=0;
    p->tonefix_end=0;
  }else{
    p->tonecomp_endp=set_aotuv_psy[select].tonecomp_endp;
    p->tonecomp_thres=set_aotuv_psy[select].tonecomp_thres;
    p->min_nn_lp=set_aotuv_psy[select].min_nn_lp;
    p->tonefix_end=set_aotuv_psy[select].tonefix_end;
  }

  /* set up the lookups for a given blocksize and sample rate */

  for(i=0,j=0;i<MAX_ATH-1;i++){
    int endpos=rint(fromOC((i+1)*.125-2.)*2*n/rate);
    float base=ATH[i];
    if(j<endpos){
      float delta=(ATH[i+1]-base)/(endpos-j);
      for(;j<endpos && j<n;j++){
        p->ath[j]=base+100.;
        base+=delta;
      }
    }
  }
  {
    float cs=p->ath[j-1];
    float ds=p->ath[j-1] - p->ath[j-2];
    for(i=j; i<n; i++, cs+=ds){
      p->ath[i]=cs;
    }
  }

  for(i=0;i<n;i++){
    float bark=toBARK(rate/(2*n)*i);

    for(;lo+vi->noisewindowlomin<i &&
          toBARK(rate/(2*n)*lo)<(bark-vi->noisewindowlo);lo++);

    for(;hi<=n && (hi<i+vi->noisewindowhimin ||
          toBARK(rate/(2*n)*hi)<(bark+vi->noisewindowhi));hi++);

    p->bark[i]=((lo-1)<<16)+(hi-1);

  }

  for(i=0;i<n;i++)
    p->octave[i]=toOC((i+.25f)*.5*rate/n)*(1<<(p->shiftoc+1))+.5f;

  p->tonecurves=setup_tone_curves(vi->toneatt,rate*.5/n,n,
                                  vi->tone_centerboost,vi->tone_decay);

  /* set up rolling noise median */
  p->noiseoffset=_ogg_malloc(P_NOISECURVES*sizeof(*p->noiseoffset));
  for(i=0;i<P_NOISECURVES;i++)
    p->noiseoffset[i]=_ogg_malloc(n*sizeof(**p->noiseoffset));

  p->ntfix_noiseoffset=_ogg_malloc(n*sizeof(*p->ntfix_noiseoffset));

  for(i=0;i<n;i++){
    float halfoc=toOC((i+.5)*rate/(2.*n))*2.;
    int inthalfoc;
    float del;

    if(halfoc<0)halfoc=0;
    if(halfoc>=P_BANDS-1)halfoc=P_BANDS-1;
    inthalfoc=(int)halfoc;
    del=halfoc-inthalfoc;

    for(j=0;j<P_NOISECURVES;j++)
      p->noiseoffset[j][i]=
        p->vi->noiseoff[j][inthalfoc]*(1.-del) +
        p->vi->noiseoff[j][inthalfoc+1]*del;

    /* setup ntfix offset */
     p->ntfix_noiseoffset[i]=ntfix_offset[inthalfoc]*(1.-del) +
                             ntfix_offset[inthalfoc+1]*del;

  }
#if 0
  {
    static int ls=0;
    _analysis_output_always("noiseoff0",ls,p->noiseoffset[0],n,1,0,0);
    _analysis_output_always("noiseoff1",ls,p->noiseoffset[1],n,1,0,0);
    _analysis_output_always("noiseoff2",ls++,p->noiseoffset[2],n,1,0,0);
  }
#endif
#ifdef __SSE__												/* SSE Optimize */
	if(findex[1]==0.f)
	{
		for(i=0;i<2048;i++)
		{
			findex[i]	 = (float)(i);
			findex2[i]	 = (float)(i*i);
		}
	}
	{
		short* sb = (short*)p->bark;
		for(i=0;i<n;i++)
		{
			if(sb[i*2+1]>=0)
				break;
		}
		p->midpoint1	 = i;
		p->midpoint1_4	 = p->midpoint1&(~3);
		p->midpoint1_8	 = p->midpoint1_4&(~7);
		p->midpoint1_16	 = p->midpoint1_8&(~15);
		for(;i<n;i++)
		{
			if(sb[i*2]>=n)
				break;
		}
		p->midpoint2	 = i;
		i = (p->midpoint1+3)&(~3);
		p->midpoint2_4	 = (p->midpoint2-i)&(~3);
		p->midpoint2_8	 = p->midpoint2_4&(~7);
		p->midpoint2_16	 = p->midpoint2_8&(~15);
		p->midpoint2_4	+= i;
		p->midpoint2_8	+= i;
		p->midpoint2_16	+= i;
	}
	p->octsft=_ogg_malloc(n*sizeof(*p->octsft));
	p->octend=_ogg_malloc(n*sizeof(*p->octend));
	p->octpos=_ogg_malloc(n*sizeof(*p->octpos));
	for(i=0;i<n;i++)
	{
		long oc	 = p->octave[i];
		oc	 = oc>>p->shiftoc;

		if(oc>=P_BANDS)oc=P_BANDS-1;
		if(oc<0)oc=0;

		p->octsft[i]	 = oc;
		p->octpos[i]	 = ((p->octave[i]+p->octave[i+1])>>1)-p->firstoc;

	}
	for(i=0;i<n;i++)
	{
		long oc=p->octave[i];
		long j = i, k;
		while(i+1<n && p->octave[i+1]==oc){
			i++;
		}
		for(k=j;k<=i;k++)
			p->octend[k] = i;
	}
#endif														/* SSE Optimize */
}

void _vp_psy_clear(vorbis_look_psy *p){
  int i,j;
  if(p){
    if(p->ath)_ogg_free(p->ath);
    if(p->octave)_ogg_free(p->octave);
    if(p->bark)_ogg_free(p->bark);
    if(p->tonecurves){
      for(i=0;i<P_BANDS;i++){
        for(j=0;j<P_LEVELS;j++){
          _ogg_free(p->tonecurves[i][j]);
        }
        _ogg_free(p->tonecurves[i]);
      }
      _ogg_free(p->tonecurves);
    }
    if(p->noiseoffset){
      for(i=0;i<P_NOISECURVES;i++){
        _ogg_free(p->noiseoffset[i]);
      }
      _ogg_free(p->noiseoffset);
    }
    if(p->ntfix_noiseoffset){
      _ogg_free(p->ntfix_noiseoffset);
    }
#ifdef __SSE__												/* SSE Optimize */
    if(p->octsft)_ogg_free(p->octsft);
    if(p->octend)_ogg_free(p->octend);
    if(p->octpos)_ogg_free(p->octpos);
#endif														/* SSE Optimize */
    memset(p,0,sizeof(*p));
  }
}

/*
  aoTuV M2
  Check extreme noise (post-echo) strength.
  This code is a temporary thing, but is effective in critical post-echo.
    Only Trans. blocks. (nn>=2048)
    ret: 'minus sign' does disable of postprocessing.
  by Aoyumi @ 2010/09/12
*/
float _postnoise_detection(float *pcm, int nn, int mode, int lw_mode){
  int i;
  int sn=nn >> 2;
  int mn=sn+sn;
  int en=sn+(nn >> 1);
  float ret=-1.0;
  double upt=0, unt=0;

  if(mode!=2)return ret; // only trans. block
  if(lw_mode!=0)return ret;
  if(nn<2048)return ret;

  for(i=sn; i<mn; i++){
    upt+=fabs(*(pcm+i));
  }
  for(i=mn; i<en; i++){
    unt+=fabs(*(pcm+i));
  }
  if(unt/sn > 0.01)return ret;

  upt*=upt;
  unt*=unt;
  unt*=15;

  if(upt>unt){
    ret=upt-unt;
    if(ret<0.1)ret=-1.0;
  }
  return ret;
}


/* octave/(8*eighth_octave_lines) x scale and dB y scale */
static void seed_curve(float *seed,
                       const float **curves,
                       const float amp,
                       const int oc, const int n,
                       const int linesper, const float dBoffset){
  int i,post1;
  int seedptr;
  const float *posts,*curve;
#ifdef __SSE__												/* SSE Optimize */
	__m128	SAMP	 = _mm_load_ss(&amp);
#endif														/* SSE Optimize */

  int choice=(int)((amp+dBoffset-P_LEVEL_0)*.1f);
  choice=max(choice,0);
  choice=min(choice,P_LEVELS-1);
  posts=curves[choice];
  curve=posts+2;
  post1=(int)posts[1];
  seedptr=oc+(posts[0]-EHMER_OFFSET)*linesper-(linesper>>1);

#ifdef __SSE__												/* SSE Optimize */
	i	 = posts[0];
	if(seedptr<0)
	{
		int preseedptr	 = seedptr;
		seedptr	 = (8-((-seedptr)&7));
		i	+= ((seedptr-preseedptr)>>3);
	}
	if((post1-i)*8+seedptr>=n)
		post1	 = (n-1-seedptr)/8+i+1;
	{
		int post05	 = ((post1-i)&(~1))+i;
		for(;i<post05;i+=2)
		{
			__m128	XMM0	 = _mm_load_ss(curve+i  );
			__m128	XMM1	 = _mm_load_ss(curve+i+1);
			__m128	XMM2	 = _mm_load_ss(seed+seedptr   );
			__m128	XMM3	 = _mm_load_ss(seed+seedptr+ 8);
			XMM0	 = _mm_add_ss(XMM0, SAMP);
			XMM1	 = _mm_add_ss(XMM1, SAMP);
			XMM0	 = _mm_max_ss(XMM0, XMM2);
			XMM1	 = _mm_max_ss(XMM1, XMM3);
			_mm_store_ss(seed+seedptr   , XMM0);
			_mm_store_ss(seed+seedptr+ 8, XMM1);
			seedptr	+= 16;
		}
		if(post1!=i)
		{
			__m128	XMM0	 = _mm_load_ss(curve+i  );
			__m128	XMM2	 = _mm_load_ss(seed+seedptr   );
			XMM0	 = _mm_add_ss(XMM0, SAMP);
			XMM0	 = _mm_max_ss(XMM0, XMM2);
			_mm_store_ss(seed+seedptr   , XMM0);
		}
	}
#else														/* SSE Optimize */
  for(i=posts[0];i<post1;i++){
    if(seedptr>0){
      float lin=amp+curve[i];
      if(seed[seedptr]<lin)seed[seedptr]=lin;
    }
    seedptr+=linesper;
    if(seedptr>=n)break;
  }
#endif														/* SSE Optimize */
}

static void seed_loop(const vorbis_look_psy *p,
                      const float ***curves,
                      const float *f,
                      const float *flr,
                      float *seed,
                      const float specmax){
  vorbis_info_psy *vi=p->vi;
  long n=p->n,i;
  float dBoffset=vi->max_curve_dB-specmax;

  /* prime the working vector with peak values */

  for(i=0;i<n;i++){
    float max=f[i];
#ifdef __SSE__												/* SSE Optimize */
	long	oc;
	long	ei=p->octend[i];
	if(i>ei)
		continue;
	oc	 = p->octave[i];
	while(i<ei)
	{
		i++;
		if(f[i]>max)max	 = f[i];
	}

	if(max+6.f>flr[i])
	{
		oc	 = p->octsft[i];
#else
    long oc=p->octave[i];
    while(i+1<n && p->octave[i+1]==oc){
      i++;
      if(f[i]>max)max=f[i];
    }

    if(max+6.f>flr[i]){
      oc=oc>>p->shiftoc;

      if(oc>=P_BANDS)oc=P_BANDS-1;
      if(oc<0)oc=0;
#endif

      seed_curve(seed,
                 curves[oc],
                 max,
                 p->octave[i]-p->firstoc,
                 p->total_octave_lines,
                 p->eighth_octave_lines,
                 dBoffset);
    }
  }
}

static void seed_chase(float *seeds, const int linesper, const long n){
  long  *posstack=alloca(n*sizeof(*posstack));
  float *ampstack=alloca(n*sizeof(*ampstack));
  long   stack=0;
  long   pos=0;
#ifdef __SSE__												/* SSE Optimize */
  long   i=0;

	for(;i<n;i++)
	{
		if(stack<2)
		{
			posstack[stack]=i;
			ampstack[stack++]=seeds[i];
		}
		else
		{
			while(1)
			{
				if(seeds[i]<ampstack[stack-1])
				{
					posstack[stack]=i;
					ampstack[stack++]=seeds[i];
					break;
				}
				else
				{
					if(i<posstack[stack-1]+linesper)
					{
						if(stack>1 && ampstack[stack-1]<=ampstack[stack-2] && i<posstack[stack-2]+linesper)
						{
							/* we completely overlap, making stack-1 irrelevant.  pop it */
							stack--;
LOOP_WITH_CHECK_STACK:
							continue;
						}
					}
					posstack[stack]=i;
					ampstack[stack++]=seeds[i];
					break;
				}
			}
			i	++;
			break;
		}
	}
	for(;i<n;i++)
	{
		while(1)
		{
			if(seeds[i]<ampstack[stack-1])
			{
				posstack[stack]=i;
				ampstack[stack++]=seeds[i];
				break;
			}
			else
			{
				if(i<posstack[stack-1]+linesper)
				{
					if(ampstack[stack-1]<=ampstack[stack-2] && i<posstack[stack-2]+linesper)
					{
						/* we completely overlap, making stack-1 irrelevant.  pop it */
						stack--;
						if(stack<2)
						{
							goto LOOP_WITH_CHECK_STACK;
						}
						else
							continue;
					}
				}
				posstack[stack]=i;
				ampstack[stack++]=seeds[i];
				break;
			}
		}
	}
#else														/* SSE Optimize */
  long   i;

  for(i=0;i<n;i++){
    if(stack<2){
      posstack[stack]=i;
      ampstack[stack++]=seeds[i];
    }else{
      while(1){
        if(seeds[i]<ampstack[stack-1]){
          posstack[stack]=i;
          ampstack[stack++]=seeds[i];
          break;
        }else{
          if(i<posstack[stack-1]+linesper){
            if(stack>1 && ampstack[stack-1]<=ampstack[stack-2] &&
               i<posstack[stack-2]+linesper){
              /* we completely overlap, making stack-1 irrelevant.  pop it */
              stack--;
              continue;
            }
          }
          posstack[stack]=i;
          ampstack[stack++]=seeds[i];
          break;

        }
      }
    }
  }
#endif														/* SSE Optimize */

  /* the stack now contains only the positions that are relevant. Scan
     'em straight through */

#ifdef __SSE__												/* SSE Optimize */
	for(i=0;i<stack-1;i++)
	{
		long endpos;
		if(ampstack[i+1]>ampstack[i])
		{
			endpos	 = posstack[i+1];
		}
		else
		{
			endpos	 = posstack[i]+linesper+1; /* +1 is important, else bin 0 is
					discarded in short frames */
		}
		if(endpos>n)
			endpos	 = n;
		for(;pos<endpos;pos++)
			seeds[pos]=ampstack[i];
	}
	if(i<stack)
	{
		long endpos;
		endpos	 = posstack[i]+linesper+1; /* +1 is important, else bin 0 is
				discarded in short frames */
		if(endpos>n)
			endpos	 = n;
		for(;pos<endpos;pos++)
			seeds[pos]=ampstack[i];
	}
#else														/* SSE Optimize */
  for(i=0;i<stack;i++){
    long endpos;
    if(i<stack-1 && ampstack[i+1]>ampstack[i]){
      endpos=posstack[i+1];
    }else{
      endpos=posstack[i]+linesper+1; /* +1 is important, else bin 0 is
                                        discarded in short frames */
    }
    if(endpos>n)endpos=n;
    for(;pos<endpos;pos++)
      seeds[pos]=ampstack[i];
  }
#endif														/* SSE Optimize */

  /* there.  Linear time.  I now remember this was on a problem set I
     had in Grad Skool... I didn't solve it at the time ;-) */

}

/* bleaugh, this is more complicated than it needs to be */
#include<stdio.h>
static void max_seeds(const vorbis_look_psy *p,
                      float *seed,
                      float *flr){
#ifdef __SSE__												/* SSE Optimize */
	long	n	 = p->total_octave_lines;
	int		linesper	 = p->eighth_octave_lines;
	long	linpos	 = 0;
	long	pos;
	float*	TEMP	 = (float*)_ogg_alloca(sizeof(float)*p->n);

	seed_chase(seed,linesper,n); /* for masking */
	{
		__m128	PVAL	 = _mm_set_ps1(p->vi->tone_abs_limit);
		long ln	 = n&(~15);
		for(pos=0;pos<ln;pos+=16)
		{
			__m128	XMM0	 = _mm_load_ps(seed+pos   );
			__m128	XMM1	 = _mm_load_ps(seed+pos+ 4);
			__m128	XMM2	 = _mm_load_ps(seed+pos+ 8);
			__m128	XMM3	 = _mm_load_ps(seed+pos+12);
			XMM0	 = _mm_min_ps(XMM0, PVAL);
			XMM1	 = _mm_min_ps(XMM1, PVAL);
			XMM2	 = _mm_min_ps(XMM2, PVAL);
			XMM3	 = _mm_min_ps(XMM3, PVAL);
			_mm_store_ps(seed+pos   , XMM0);
			_mm_store_ps(seed+pos+ 4, XMM1);
			_mm_store_ps(seed+pos+ 8, XMM2);
			_mm_store_ps(seed+pos+12, XMM3);
		}
		ln	 = n&(~7);
		for(;pos<ln;pos+=8)
		{
			__m128	XMM0	 = _mm_load_ps(seed+pos   );
			__m128	XMM1	 = _mm_load_ps(seed+pos+ 4);
			XMM0	 = _mm_min_ps(XMM0, PVAL);
			XMM1	 = _mm_min_ps(XMM1, PVAL);
			_mm_store_ps(seed+pos   , XMM0);
			_mm_store_ps(seed+pos+ 4, XMM1);
		}
		ln	 = n&(~3);
		for(;pos<ln;pos+=4)
		{
			__m128	XMM0	 = _mm_load_ps(seed+pos   );
			XMM0	 = _mm_min_ps(XMM0, PVAL);
			_mm_store_ps(seed+pos   , XMM0);
		}
		for(;pos<n;pos++)
		{
			__m128	XMM0	 = _mm_load_ss(seed+pos   );
			XMM0	 = _mm_min_ss(XMM0, PVAL);
			_mm_store_ss(seed+pos, XMM0);
		}
	}
	pos	 = p->octave[0]-p->firstoc-(linesper>>1);
	if(linpos+1<p->n)
	{
		float minV	 = seed[pos];
		long end	 = p->octpos[linpos];
		while(pos+1<=end)
		{
			pos	++;
			if((seed[pos]>NEGINF && seed[pos]<minV) || minV==NEGINF)
				minV	 = seed[pos];
		}
		end	 = pos+p->firstoc;
		for(;linpos<p->n&&p->octave[linpos]<=end;)
		{
			int ep = p->octend[linpos];
			for(;linpos<=ep;linpos++)
				TEMP[linpos]	 = minV;
		}
	}
	while(linpos+1<p->n)
	{
		float minV	 = seed[pos];
		long end	 = p->octpos[linpos];
		while(pos+1<=end)
		{
			pos	++;
			if(seed[pos]<minV)
				minV	 = seed[pos];
		}
		end	 = pos+p->firstoc;
		for(;linpos<p->n&&p->octave[linpos]<=end;)
		{
			int ep = p->octend[linpos];
			for(;linpos<=ep;linpos++)
				TEMP[linpos]	 = minV;
		}
	}

	{
		float minV	 = seed[p->total_octave_lines-1];
		for(;linpos<p->n;linpos++)
			TEMP[linpos]	 = minV;
	}
	{
		for(pos=0;pos<p->n;pos+=16)
		{
			__m128	XMM0	 = _mm_load_ps(flr+pos    );
			__m128	XMM4	 = _mm_load_ps(TEMP+pos   );
			__m128	XMM1	 = _mm_load_ps(flr+pos+  4);
			__m128	XMM5	 = _mm_load_ps(TEMP+pos+ 4);
			__m128	XMM2	 = _mm_load_ps(flr+pos+  8);
			__m128	XMM6	 = _mm_load_ps(TEMP+pos+ 8);
			__m128	XMM3	 = _mm_load_ps(flr+pos+ 12);
			__m128	XMM7	 = _mm_load_ps(TEMP+pos+12);
			XMM0	 = _mm_max_ps(XMM0, XMM4);
			XMM1	 = _mm_max_ps(XMM1, XMM5);
			XMM2	 = _mm_max_ps(XMM2, XMM6);
			XMM3	 = _mm_max_ps(XMM3, XMM7);
			_mm_store_ps(flr+pos   , XMM0);
			_mm_store_ps(flr+pos+ 4, XMM1);
			_mm_store_ps(flr+pos+ 8, XMM2);
			_mm_store_ps(flr+pos+12, XMM3);
		}
	}
#else														/* SSE Optimize */
  long   n=p->total_octave_lines;
  int    linesper=p->eighth_octave_lines;
  long   linpos=0;
  long   pos;

  seed_chase(seed,linesper,n); /* for masking */

  pos=p->octave[0]-p->firstoc-(linesper>>1);

  while(linpos+1<p->n){
    float minV=seed[pos];
    long end=((p->octave[linpos]+p->octave[linpos+1])>>1)-p->firstoc;
    if(minV>p->vi->tone_abs_limit)minV=p->vi->tone_abs_limit;
    while(pos+1<=end){
      pos++;
      if((seed[pos]>NEGINF && seed[pos]<minV) || minV==NEGINF)
        minV=seed[pos];
    }

    end=pos+p->firstoc;
    for(;linpos<p->n && p->octave[linpos]<=end;linpos++)
      if(flr[linpos]<minV)flr[linpos]=minV;
  }

  {
    float minV=seed[p->total_octave_lines-1];
    for(;linpos<p->n;linpos++)
      if(flr[linpos]<minV)flr[linpos]=minV;
  }

#endif														/* SSE Optimize */
}

#ifdef __SSE__												/* SSE Optimize */
/*
	A	 = tY * tXX - tX * tXY;
	B	 = tN * tXY - tX * tY;
	D	 = tN * tXX - tX * tX;
	R	 = (A + x * B) / D;

	Input
	TN		(N3 ,N2 ,N1 ,N0 )
	XMM0	 = (XY0,Y0 ,XX0,X0 )
	XMM1	 = (XY1,Y1 ,XX1,X1 )
	XMM4	 = (XY2,Y2 ,XX2,X2 )
	XMM3	 = (XY3,Y3 ,XX3,X3 )

	Phase 1.

	Phase 2.
	XMM0	 = 	(X3 ,X2 ,X1 ,X0 )
	XMM1	 = 	(XX3,XX2,XX1,XX0)
	XMM2	 = 	(Y3 ,Y2 ,Y1 ,Y0 )
	XMM3	 = 	(XY3,XY2,XY1,XY0)

	Phase 3.
	XMM4	 = Y*XX
	XMM5	 = X*XY
	XMM6	 = XY*TN
	XMM7	 = X*Y

	Phase 4.
	XMM4	 = Y*XX - X*XY	... A
	XMM5	 = XY*TN - X*Y	... B
	XMM6	 = XX*TN
	XMM7	 = X*X
	XMM1	 = XX*TN - X*X	... D

	Phase 5.
	XMM4	 = PX*B
	XMM4	 = PX*B+A
	XMM4	 = (A+PX*B)/D
*/
#define bark_noise_hybridmp_SSE_SUBC()										\
{																			\
	__m128 XMM2, XMM5, XMM6, XMM7;											\
	XMM2 = XMM0;															\
	XMM5 = XMM4;															\
	XMM0	 = _mm_shuffle_ps(XMM0, XMM1, _MM_SHUFFLE(1,0,1,0));			\
	XMM2	 = _mm_shuffle_ps(XMM2, XMM1, _MM_SHUFFLE(3,2,3,2));			\
	XMM4	 = _mm_shuffle_ps(XMM4, XMM3, _MM_SHUFFLE(1,0,1,0));			\
	XMM5	 = _mm_shuffle_ps(XMM5, XMM3, _MM_SHUFFLE(3,2,3,2));			\
	XMM1 = XMM0;															\
	XMM3 = XMM2;															\
	XMM0	 = _mm_shuffle_ps(XMM0, XMM4, _MM_SHUFFLE(2,0,2,0));			\
	XMM1	 = _mm_shuffle_ps(XMM1, XMM4, _MM_SHUFFLE(3,1,3,1));			\
	XMM2	 = _mm_shuffle_ps(XMM2, XMM5, _MM_SHUFFLE(2,0,2,0));			\
	XMM3	 = _mm_shuffle_ps(XMM3, XMM5, _MM_SHUFFLE(3,1,3,1));			\
	XMM4 = XMM2;															\
	XMM5 = XMM0;															\
	XMM6 = XMM3;															\
	XMM7 = XMM0;															\
	XMM4 = _mm_mul_ps(XMM4, XMM1);											\
	XMM5 = _mm_mul_ps(XMM5, XMM3);											\
	XMM3 = _mm_load_ps(findex+i);											\
	XMM6 = _mm_mul_ps(XMM6, TN.ps);											\
	XMM1 = _mm_mul_ps(XMM1, TN.ps);											\
	XMM7 = _mm_mul_ps(XMM7, XMM2);											\
	XMM0 = _mm_mul_ps(XMM0, XMM0);											\
	XMM4 = _mm_sub_ps(XMM4, XMM5);											\
	XMM6 = _mm_sub_ps(XMM6, XMM7);											\
	XMM1 = _mm_sub_ps(XMM1, XMM0);											\
	XMM6 = _mm_mul_ps(XMM6, XMM3);											\
	XMM3 = _mm_rcp_ps(XMM1);												\
	XMM4 = _mm_add_ps(XMM4, XMM6);											\
	XMM1 = _mm_mul_ps(XMM1, XMM3);											\
	XMM1 = _mm_mul_ps(XMM1, XMM3);											\
	XMM3 = _mm_add_ps(XMM3, XMM3);											\
	XMM3 = _mm_sub_ps(XMM3, XMM1);											\
	XMM4 = _mm_mul_ps(XMM4, XMM3);											\
}
#define bark_noise_hybridmp_SSE_SUBC2()										\
{																			\
	__m128 XMM2, XMM5, XMM6, XMM7;											\
	XMM2 = XMM0;															\
	XMM5 = XMM4;															\
	XMM0	 = _mm_shuffle_ps(XMM0, XMM1, _MM_SHUFFLE(1,0,1,0));			\
	XMM2	 = _mm_shuffle_ps(XMM2, XMM1, _MM_SHUFFLE(3,2,3,2));			\
	XMM4	 = _mm_shuffle_ps(XMM4, XMM3, _MM_SHUFFLE(1,0,1,0));			\
	XMM5	 = _mm_shuffle_ps(XMM5, XMM3, _MM_SHUFFLE(3,2,3,2));			\
	XMM1 = XMM0;															\
	XMM3 = XMM2;															\
	XMM0	 = _mm_shuffle_ps(XMM0, XMM4, _MM_SHUFFLE(2,0,2,0));			\
	XMM1	 = _mm_shuffle_ps(XMM1, XMM4, _MM_SHUFFLE(3,1,3,1));			\
	XMM2	 = _mm_shuffle_ps(XMM2, XMM5, _MM_SHUFFLE(2,0,2,0));			\
	XMM3	 = _mm_shuffle_ps(XMM3, XMM5, _MM_SHUFFLE(3,1,3,1));			\
	XMM4 = XMM2;															\
	XMM5 = XMM0;															\
	XMM6 = XMM3;															\
	XMM7 = XMM0;															\
	XMM4 = _mm_mul_ps(XMM4, XMM1);											\
	XMM5 = _mm_mul_ps(XMM5, XMM3);											\
	XMM3 = _mm_load_ps(findex+i);											\
	XMM6 = _mm_mul_ps(XMM6, TN.ps);											\
	XMM1 = _mm_mul_ps(XMM1, TN.ps);											\
	XMM7 = _mm_mul_ps(XMM7, XMM2);											\
	XMM0 = _mm_mul_ps(XMM0, XMM0);											\
	XMM4 = _mm_sub_ps(XMM4, XMM5);											\
	XMM6 = _mm_sub_ps(XMM6, XMM7);											\
	XMM1 = _mm_sub_ps(XMM1, XMM0);											\
	PA	 = XMM4;															\
	PB	 = XMM6;															\
	XMM6 = _mm_mul_ps(XMM6, XMM3);											\
	XMM3 = _mm_rcp_ps(XMM1);												\
	XMM4 = _mm_add_ps(XMM4, XMM6);											\
	XMM1 = _mm_mul_ps(XMM1, XMM3);											\
	XMM1 = _mm_mul_ps(XMM1, XMM3);											\
	XMM3 = _mm_add_ps(XMM3, XMM3);											\
	XMM3 = _mm_sub_ps(XMM3, XMM1);											\
	PD	 = XMM3;															\
	XMM4 = _mm_mul_ps(XMM4, XMM3);											\
}
#endif														/* SSE Optimize */

#ifdef __SSE__												/* SSE Optimize */
static void bark_noise_hybridmp(const vorbis_look_psy *p,
								const float *f,
								float *noise,
								const float offset,
								const int fixed,
								float *work,
								float *tf){
	int		n = p->n;
	float	*N		 = work;
	__m128	*XXYY	 = (__m128*)(N+n);
	float	*xxyy	 = N+n;
	short	*sb	 = (short*)p->bark;

	int		i, j;
	int		lo, hi;
	int		midpoint1, midpoint2;
	float	tN, tX, tXX, tY, tXY;
	float R=0.f;
	float A=0.f;
	float B=0.f;
	float D=1.f;
	float	x;
	float	*TN = N;
	__m128	*TXXYY = XXYY;

	__m128	OFFSET;
	__m128	PXXYY	 = _mm_setzero_ps();
	__m128	PA, PB, PD;
	_MM_ALIGN16 __m128	TEMP[16];
	int	p0, p1;

	// Phase 1
	_mm_prefetch((const char*)(f     ), _MM_HINT_NTA);
	_mm_prefetch((const char*)(findex2     ), _MM_HINT_NTA);
	_mm_prefetch((const char*)(f  +16), _MM_HINT_NTA);
	_mm_prefetch((const char*)(findex2  +16), _MM_HINT_NTA);
	OFFSET	 = _mm_set_ps1(offset);
	{
		__m128	XMM0	 = _mm_load_ps(f   );
		__m128	XMM1	 = _mm_load_ps(f+ 4);
		__m128	XMM2	 = _mm_load_ps(f+ 8);
		__m128	XMM3	 = _mm_load_ps(f+12);
		__m128	XMM4, XMM5, XMM6, XMM7;
		XMM4	 = OFFSET;
		XMM5	 = _mm_load_ps(PFV_1);
		XMM0	 = _mm_add_ps(XMM0, XMM4);
		XMM1	 = _mm_add_ps(XMM1, XMM4);
		XMM2	 = _mm_add_ps(XMM2, XMM4);
		XMM3	 = _mm_add_ps(XMM3, XMM4);
		XMM0	 = _mm_max_ps(XMM0, XMM5);
		XMM1	 = _mm_max_ps(XMM1, XMM5);
		XMM2	 = _mm_max_ps(XMM2, XMM5);
		XMM3	 = _mm_max_ps(XMM3, XMM5);
		XMM4	 = XMM0;
		XMM5	 = XMM1;
		XMM6	 = XMM2;
		XMM7	 = XMM3;
		XMM0	 = _mm_mul_ps(XMM0, XMM0);
		XMM1	 = _mm_mul_ps(XMM1, XMM1);
		XMM2	 = _mm_mul_ps(XMM2, XMM2);
		XMM3	 = _mm_mul_ps(XMM3, XMM3);
		_mm_store_ps(TN   , XMM0);	/* N */
		_mm_store_ps(TN+ 4, XMM1);
		_mm_store_ps(TN+ 8, XMM2);
		_mm_store_ps(TN+12, XMM3);
		XMM0	 = _mm_mul_ps(XMM0, XMM4);
		XMM1	 = _mm_mul_ps(XMM1, XMM5);
		XMM2	 = _mm_mul_ps(XMM2, XMM6);
		XMM3	 = _mm_mul_ps(XMM3, XMM7);
		TEMP[ 1]	 = XMM0;	/* Y */
		PXXYY	 = _mm_move_ss(PXXYY, TEMP[1]);
		XMM4	 = _mm_load_ps(findex   );
		TEMP[ 5]	 = XMM1;
		XMM5	 = _mm_load_ps(findex+ 4);
		TEMP[ 9]	 = XMM2;
		XMM6	 = _mm_load_ps(findex+ 8);
		TEMP[13]	 = XMM3;
		XMM7	 = _mm_load_ps(findex+12);
		XMM0	 = _mm_mul_ps(XMM0, XMM4);
		XMM1	 = _mm_mul_ps(XMM1, XMM5);
		XMM2	 = _mm_mul_ps(XMM2, XMM6);
		XMM3	 = _mm_mul_ps(XMM3, XMM7);
		TEMP[ 3]	 = XMM0;	/* XY */
		TEMP[ 7]	 = XMM1;
		TEMP[11]	 = XMM2;
		TEMP[15]	 = XMM3;
		XMM0	 = _mm_load_ps(TN   );	/* N */
		XMM1	 = _mm_load_ps(TN+ 4);
		XMM2	 = _mm_load_ps(TN+ 8);
		XMM3	 = _mm_load_ps(TN+12);
		XMM4	 = _mm_mul_ps(XMM4, XMM0);
		XMM5	 = _mm_mul_ps(XMM5, XMM1);
		XMM6	 = _mm_mul_ps(XMM6, XMM2);
		XMM7	 = _mm_mul_ps(XMM7, XMM3);
		TEMP[ 0]	 = XMM4;	/* X */
		TEMP[ 4]	 = XMM5;
		TEMP[ 8]	 = XMM6;
		TEMP[12]	 = XMM7;
		XMM4	 = _mm_load_ps(findex2   );
		XMM5	 = _mm_load_ps(findex2+ 4);
		XMM6	 = _mm_load_ps(findex2+ 8);
		XMM7	 = _mm_load_ps(findex2+12);
		XMM0	 = _mm_mul_ps(XMM0, XMM4);
		XMM4	 = TEMP[0];	// X
		XMM1	 = _mm_mul_ps(XMM1, XMM5);
		XMM5	 = TEMP[1];	// Y
		XMM2	 = _mm_mul_ps(XMM2, XMM6);
		XMM6	 = XMM0;	// XX
		XMM3	 = _mm_mul_ps(XMM3, XMM7);
		XMM7	 = TEMP[3];	// XY
		XMM0	 = XMM4;
		TEMP[ 6]	 = XMM1;
		XMM1	 = XMM5;
		// i=0-3
		// PXXYY	 = (0, 0, 0, Y^2)
		XMM4	 = _mm_shuffle_ps(XMM4, XMM6, _MM_SHUFFLE(1,0,1,0));
		XMM0	 = _mm_shuffle_ps(XMM0, XMM6, _MM_SHUFFLE(3,2,3,2));
		TEMP[10]	 = XMM2;
		XMM5	 = _mm_shuffle_ps(XMM5, XMM7, _MM_SHUFFLE(1,0,1,0));
		XMM1	 = _mm_shuffle_ps(XMM1, XMM7, _MM_SHUFFLE(3,2,3,2));
		TEMP[14]	 = XMM3;
		XMM6	 = XMM4;
		XMM7	 = XMM0;
		XMM4	 = _mm_shuffle_ps(XMM4, XMM5, _MM_SHUFFLE(2,0,2,0));
		XMM6	 = _mm_shuffle_ps(XMM6, XMM5, _MM_SHUFFLE(3,1,3,1));
		XMM5	 = TEMP[ 4];	// X
		XMM0	 = _mm_shuffle_ps(XMM0, XMM1, _MM_SHUFFLE(2,0,2,0));
		XMM7	 = _mm_shuffle_ps(XMM7, XMM1, _MM_SHUFFLE(3,1,3,1));
		XMM1	 = TEMP[ 5];	// Y
		// XXYY[i+0]	 = (XY,  Y, XX,  X)	 = (0, Y^3, 0, 0)
		// To Fix (0, Y^3*.5f, 0, Y^2*.5f)
		XMM4	 = _mm_add_ps(XMM4, PXXYY);
		TN[ 0]	*= 0.5;
		XMM4	 = _mm_mul_ps(XMM4, PM128(PFV_0P5));
		TN[ 1]	+= TN[ 0];
		XMM6	 = _mm_add_ps(XMM6, XMM4);
		TN[ 2]	+= TN[ 1];
		XMM0	 = _mm_add_ps(XMM0, XMM6);
		TN[ 3]	+= TN[ 2];
		XMM7	 = _mm_add_ps(XMM7, XMM0);
		TXXYY[ 0]	 = XMM4;
		XMM4	 = TEMP[ 6];	// XX
		TXXYY[ 1]	 = XMM6;
		XMM6	 = TEMP[ 7];	// XY
		TXXYY[ 2]	 = XMM0;
		XMM0	 = XMM5;
		TXXYY[ 3]	 = XMM7;
		XMM7	 = XMM1;
		XMM5	 = _mm_shuffle_ps(XMM5, XMM4, _MM_SHUFFLE(1,0,1,0));
		XMM0	 = _mm_shuffle_ps(XMM0, XMM4, _MM_SHUFFLE(3,2,3,2));
		XMM1	 = _mm_shuffle_ps(XMM1, XMM6, _MM_SHUFFLE(1,0,1,0));
		XMM7	 = _mm_shuffle_ps(XMM7, XMM6, _MM_SHUFFLE(3,2,3,2));
		XMM4	 = XMM5;
		XMM6	 = XMM0;
		XMM5	 = _mm_shuffle_ps(XMM5, XMM1, _MM_SHUFFLE(2,0,2,0));
		XMM4	 = _mm_shuffle_ps(XMM4, XMM1, _MM_SHUFFLE(3,1,3,1));
		XMM1	 = TEMP[ 8];	// X
		XMM0	 = _mm_shuffle_ps(XMM0, XMM7, _MM_SHUFFLE(2,0,2,0));
		XMM6	 = _mm_shuffle_ps(XMM6, XMM7, _MM_SHUFFLE(3,1,3,1));
		XMM7	 = TEMP[ 9];	// Y
		XMM5	 = _mm_add_ps(XMM5, TXXYY[ 3]);
		TN[ 4]	+= TN[ 3];
		XMM4	 = _mm_add_ps(XMM4, XMM5);
		TN[ 5]	+= TN[ 4];
		XMM0	 = _mm_add_ps(XMM0, XMM4);
		TN[ 6]	+= TN[ 5];
		XMM6	 = _mm_add_ps(XMM6, XMM0);
		TN[ 7]	+= TN[ 6];
		TXXYY[ 4]	 = XMM5;
		XMM5	 = TEMP[10];	// XX
		TXXYY[ 5]	 = XMM4;
		XMM4	 = TEMP[11];	// XY
		TXXYY[ 6]	 = XMM0;
		XMM0	 = XMM1;
		TXXYY[ 7]	 = XMM6;
		XMM6	 = XMM7;
		XMM1	 = _mm_shuffle_ps(XMM1, XMM5, _MM_SHUFFLE(1,0,1,0));
		XMM0	 = _mm_shuffle_ps(XMM0, XMM5, _MM_SHUFFLE(3,2,3,2));
		XMM7	 = _mm_shuffle_ps(XMM7, XMM4, _MM_SHUFFLE(1,0,1,0));
		XMM6	 = _mm_shuffle_ps(XMM6, XMM4, _MM_SHUFFLE(3,2,3,2));
		XMM5	 = XMM1;
		XMM4	 = XMM0;
		XMM1	 = _mm_shuffle_ps(XMM1, XMM7, _MM_SHUFFLE(2,0,2,0));
		XMM5	 = _mm_shuffle_ps(XMM5, XMM7, _MM_SHUFFLE(3,1,3,1));
		XMM7	 = TEMP[12];	// X
		XMM0	 = _mm_shuffle_ps(XMM0, XMM6, _MM_SHUFFLE(2,0,2,0));
		XMM4	 = _mm_shuffle_ps(XMM4, XMM6, _MM_SHUFFLE(3,1,3,1));
		XMM6	 = TEMP[13];	// Y
		XMM1	 = _mm_add_ps(XMM1, TXXYY[ 7]);
		TN[ 8]	+= TN[ 7];
		XMM5	 = _mm_add_ps(XMM5, XMM1);
		TN[ 9]	+= TN[ 8];
		XMM0	 = _mm_add_ps(XMM0, XMM5);
		TN[10]	+= TN[ 9];
		XMM4	 = _mm_add_ps(XMM4, XMM0);
		TN[11]	+= TN[10];
		TXXYY[ 8]	 = XMM1;
		XMM1	 = TEMP[14];	// XX
		TXXYY[ 9]	 = XMM5;
		XMM5	 = TEMP[15];	// XY
		TXXYY[10]	 = XMM0;
		XMM0	 = XMM7;
		TXXYY[11]	 = XMM4;
		XMM4	 = XMM6;
		XMM7	 = _mm_shuffle_ps(XMM7, XMM1, _MM_SHUFFLE(1,0,1,0));
		XMM0	 = _mm_shuffle_ps(XMM0, XMM1, _MM_SHUFFLE(3,2,3,2));
		XMM6	 = _mm_shuffle_ps(XMM6, XMM5, _MM_SHUFFLE(1,0,1,0));
		XMM4	 = _mm_shuffle_ps(XMM4, XMM5, _MM_SHUFFLE(3,2,3,2));
		XMM1	 = XMM7;
		XMM5	 = XMM0;
		XMM7	 = _mm_shuffle_ps(XMM7, XMM6, _MM_SHUFFLE(2,0,2,0));
		XMM1	 = _mm_shuffle_ps(XMM1, XMM6, _MM_SHUFFLE(3,1,3,1));
		XMM0	 = _mm_shuffle_ps(XMM0, XMM4, _MM_SHUFFLE(2,0,2,0));
		XMM5	 = _mm_shuffle_ps(XMM5, XMM4, _MM_SHUFFLE(3,1,3,1));
		XMM7	 = _mm_add_ps(XMM7, TXXYY[11]);
		TN[12]	+= TN[11];
		XMM1	 = _mm_add_ps(XMM1, XMM7);
		TN[13]	+= TN[12];
		XMM0	 = _mm_add_ps(XMM0, XMM1);
		TN[14]	+= TN[13];
		XMM5	 = _mm_add_ps(XMM5, XMM0);
		TN[15]	+= TN[14];
		TXXYY[12]	 = XMM7;
		TXXYY[13]	 = XMM1;
		TXXYY[14]	 = XMM0;
		TXXYY[15]	 = XMM5;
		TN		+= 16;
		TXXYY	+= 16;
	}
	for(i=16;i<n;i+=16)
	{
		__m128	XMM0, XMM1, XMM2, XMM3;
		__m128	XMM4, XMM5, XMM6, XMM7;
		_mm_prefetch((const char*)(f+i+16), _MM_HINT_NTA);
		_mm_prefetch((const char*)(findex2+i+16), _MM_HINT_NTA);
		XMM0	 = _mm_load_ps(f+i   );
		XMM1	 = _mm_load_ps(f+i+ 4);
		XMM2	 = _mm_load_ps(f+i+ 8);
		XMM3	 = _mm_load_ps(f+i+12);
		XMM4	 = OFFSET;
		XMM5	 = _mm_load_ps(PFV_1);
		XMM0	 = _mm_add_ps(XMM0, XMM4);
		XMM1	 = _mm_add_ps(XMM1, XMM4);
		XMM2	 = _mm_add_ps(XMM2, XMM4);
		XMM3	 = _mm_add_ps(XMM3, XMM4);
		XMM0	 = _mm_max_ps(XMM0, XMM5);
		XMM1	 = _mm_max_ps(XMM1, XMM5);
		XMM2	 = _mm_max_ps(XMM2, XMM5);
		XMM3	 = _mm_max_ps(XMM3, XMM5);
		XMM4	 = XMM0;
		XMM5	 = XMM1;
		XMM6	 = XMM2;
		XMM7	 = XMM3;
		XMM0	 = _mm_mul_ps(XMM0, XMM0);
		XMM1	 = _mm_mul_ps(XMM1, XMM1);
		XMM2	 = _mm_mul_ps(XMM2, XMM2);
		XMM3	 = _mm_mul_ps(XMM3, XMM3);
		_mm_store_ps(TN   , XMM0);
		_mm_store_ps(TN+ 4, XMM1);
		_mm_store_ps(TN+ 8, XMM2);
		_mm_store_ps(TN+12, XMM3);
		XMM0	 = _mm_mul_ps(XMM0, XMM4);
		XMM1	 = _mm_mul_ps(XMM1, XMM5);
		XMM2	 = _mm_mul_ps(XMM2, XMM6);
		XMM3	 = _mm_mul_ps(XMM3, XMM7);
		TEMP[ 1]	 = XMM0;	/* Y */
		XMM4	 = _mm_load_ps(findex+i   );
		TEMP[ 5]	 = XMM1;
		XMM5	 = _mm_load_ps(findex+i+ 4);
		TEMP[ 9]	 = XMM2;
		XMM6	 = _mm_load_ps(findex+i+ 8);
		TEMP[13]	 = XMM3;
		XMM7	 = _mm_load_ps(findex+i+12);
		XMM0	 = _mm_mul_ps(XMM0, XMM4);
		XMM1	 = _mm_mul_ps(XMM1, XMM5);
		XMM2	 = _mm_mul_ps(XMM2, XMM6);
		XMM3	 = _mm_mul_ps(XMM3, XMM7);
		TEMP[ 3]	 = XMM0;	/* XY */
		TEMP[ 7]	 = XMM1;
		TEMP[11]	 = XMM2;
		TEMP[15]	 = XMM3;
		XMM0	 = _mm_load_ps(TN   );	/* N */
		XMM1	 = _mm_load_ps(TN+ 4);
		XMM2	 = _mm_load_ps(TN+ 8);
		XMM3	 = _mm_load_ps(TN+12);
		XMM4	 = _mm_mul_ps(XMM4, XMM0);
		XMM5	 = _mm_mul_ps(XMM5, XMM1);
		XMM6	 = _mm_mul_ps(XMM6, XMM2);
		XMM7	 = _mm_mul_ps(XMM7, XMM3);
		TEMP[ 0]	 = XMM4;	/* X */
		TEMP[ 4]	 = XMM5;
		TEMP[ 8]	 = XMM6;
		TEMP[12]	 = XMM7;
		XMM4	 = _mm_load_ps(findex2+i   );
		XMM5	 = _mm_load_ps(findex2+i+ 4);
		XMM6	 = _mm_load_ps(findex2+i+ 8);
		XMM7	 = _mm_load_ps(findex2+i+12);
		XMM0	 = _mm_mul_ps(XMM0, XMM4);
		XMM4	 = TEMP[ 0];	// X
		XMM1	 = _mm_mul_ps(XMM1, XMM5);
		XMM5	 = TEMP[ 1];	// Y
		XMM2	 = _mm_mul_ps(XMM2, XMM6);
		XMM6	 = XMM0;	/* XX */
		XMM0	 = XMM4;
		XMM3	 = _mm_mul_ps(XMM3, XMM7);
		XMM7	 = TEMP[ 3];	// XY
		TEMP[ 6]	 = XMM1;
		XMM1	 = XMM5;
		XMM4	 = _mm_shuffle_ps(XMM4, XMM6, _MM_SHUFFLE(1,0,1,0));
		XMM0	 = _mm_shuffle_ps(XMM0, XMM6, _MM_SHUFFLE(3,2,3,2));
		TEMP[10]	 = XMM2;
		XMM5	 = _mm_shuffle_ps(XMM5, XMM7, _MM_SHUFFLE(1,0,1,0));
		XMM1	 = _mm_shuffle_ps(XMM1, XMM7, _MM_SHUFFLE(3,2,3,2));
		TEMP[14]	 = XMM3;
		XMM6	 = XMM4;
		XMM7	 = XMM0;
		XMM4	 = _mm_shuffle_ps(XMM4, XMM5, _MM_SHUFFLE(2,0,2,0));
		XMM6	 = _mm_shuffle_ps(XMM6, XMM5, _MM_SHUFFLE(3,1,3,1));
		XMM5	 = TEMP[ 4];	// X
		XMM0	 = _mm_shuffle_ps(XMM0, XMM1, _MM_SHUFFLE(2,0,2,0));
		XMM7	 = _mm_shuffle_ps(XMM7, XMM1, _MM_SHUFFLE(3,1,3,1));
		XMM1	 = TEMP[ 5];	// Y
		XMM4	 = _mm_add_ps(XMM4, TXXYY[-1]);
		TN[ 0]	+= TN[-1];
		XMM6	 = _mm_add_ps(XMM6, XMM4);
		TN[ 1]	+= TN[ 0];
		XMM0	 = _mm_add_ps(XMM0, XMM6);
		TN[ 2]	+= TN[ 1];
		XMM7	 = _mm_add_ps(XMM7, XMM0);
		TN[ 3]	+= TN[ 2];
		TXXYY[ 0]	 = XMM4;
		XMM4	 = TEMP[ 6];	// XX
		TXXYY[ 1]	 = XMM6;
		XMM6	 = TEMP[ 7];	// XY
		TXXYY[ 2]	 = XMM0;
		XMM0	 = XMM5;
		TXXYY[ 3]	 = XMM7;
		XMM7	 = XMM1;
		XMM5	 = _mm_shuffle_ps(XMM5, XMM4, _MM_SHUFFLE(1,0,1,0));
		XMM0	 = _mm_shuffle_ps(XMM0, XMM4, _MM_SHUFFLE(3,2,3,2));
		XMM1	 = _mm_shuffle_ps(XMM1, XMM6, _MM_SHUFFLE(1,0,1,0));
		XMM7	 = _mm_shuffle_ps(XMM7, XMM6, _MM_SHUFFLE(3,2,3,2));
		XMM4	 = XMM5;
		XMM6	 = XMM0;
		XMM5	 = _mm_shuffle_ps(XMM5, XMM1, _MM_SHUFFLE(2,0,2,0));
		XMM4	 = _mm_shuffle_ps(XMM4, XMM1, _MM_SHUFFLE(3,1,3,1));
		XMM1	 = TEMP[ 8];	// X
		XMM0	 = _mm_shuffle_ps(XMM0, XMM7, _MM_SHUFFLE(2,0,2,0));
		XMM6	 = _mm_shuffle_ps(XMM6, XMM7, _MM_SHUFFLE(3,1,3,1));
		XMM7	 = TEMP[ 9];	// Y
		XMM5	 = _mm_add_ps(XMM5, TXXYY[ 3]);
		TN[ 4]	+= TN[ 3];
		XMM4	 = _mm_add_ps(XMM4, XMM5);
		TN[ 5]	+= TN[ 4];
		XMM0	 = _mm_add_ps(XMM0, XMM4);
		TN[ 6]	+= TN[ 5];
		XMM6	 = _mm_add_ps(XMM6, XMM0);
		TN[ 7]	+= TN[ 6];
		TXXYY[ 4]	 = XMM5;
		XMM5	 = TEMP[10];	// XX
		TXXYY[ 5]	 = XMM4;
		XMM4	 = TEMP[11];	// XY
		TXXYY[ 6]	 = XMM0;
		XMM0	 = XMM1;
		TXXYY[ 7]	 = XMM6;
		XMM6	 = XMM7;
		XMM1	 = _mm_shuffle_ps(XMM1, XMM5, _MM_SHUFFLE(1,0,1,0));
		XMM0	 = _mm_shuffle_ps(XMM0, XMM5, _MM_SHUFFLE(3,2,3,2));
		XMM7	 = _mm_shuffle_ps(XMM7, XMM4, _MM_SHUFFLE(1,0,1,0));
		XMM6	 = _mm_shuffle_ps(XMM6, XMM4, _MM_SHUFFLE(3,2,3,2));
		XMM5	 = XMM1;
		XMM4	 = XMM0;
		XMM1	 = _mm_shuffle_ps(XMM1, XMM7, _MM_SHUFFLE(2,0,2,0));
		XMM5	 = _mm_shuffle_ps(XMM5, XMM7, _MM_SHUFFLE(3,1,3,1));
		XMM7	 = TEMP[12];	// X
		XMM0	 = _mm_shuffle_ps(XMM0, XMM6, _MM_SHUFFLE(2,0,2,0));
		XMM4	 = _mm_shuffle_ps(XMM4, XMM6, _MM_SHUFFLE(3,1,3,1));
		XMM6	 = TEMP[13];	// Y
		XMM1	 = _mm_add_ps(XMM1, TXXYY[ 7]);
		TN[ 8]	+= TN[ 7];
		XMM5	 = _mm_add_ps(XMM5, XMM1);
		TN[ 9]	+= TN[ 8];
		XMM0	 = _mm_add_ps(XMM0, XMM5);
		TN[10]	+= TN[ 9];
		XMM4	 = _mm_add_ps(XMM4, XMM0);
		TN[11]	+= TN[10];
		TXXYY[ 8]	 = XMM1;
		XMM1	 = TEMP[14];	// XX
		TXXYY[ 9]	 = XMM5;
		XMM5	 = TEMP[15];	// XY
		TXXYY[10]	 = XMM0;
		XMM0	 = XMM7;
		TXXYY[11]	 = XMM4;
		XMM4	 = XMM6;
		XMM7	 = _mm_shuffle_ps(XMM7, XMM1, _MM_SHUFFLE(1,0,1,0));
		XMM0	 = _mm_shuffle_ps(XMM0, XMM1, _MM_SHUFFLE(3,2,3,2));
		XMM6	 = _mm_shuffle_ps(XMM6, XMM5, _MM_SHUFFLE(1,0,1,0));
		XMM4	 = _mm_shuffle_ps(XMM4, XMM5, _MM_SHUFFLE(3,2,3,2));
		XMM1	 = XMM7;
		XMM5	 = XMM0;
		XMM7	 = _mm_shuffle_ps(XMM7, XMM6, _MM_SHUFFLE(2,0,2,0));
		XMM1	 = _mm_shuffle_ps(XMM1, XMM6, _MM_SHUFFLE(3,1,3,1));
		XMM0	 = _mm_shuffle_ps(XMM0, XMM4, _MM_SHUFFLE(2,0,2,0));
		XMM5	 = _mm_shuffle_ps(XMM5, XMM4, _MM_SHUFFLE(3,1,3,1));
		XMM7	 = _mm_add_ps(XMM7, TXXYY[11]);
		TN[12]	+= TN[11];
		XMM1	 = _mm_add_ps(XMM1, XMM7);
		TN[13]	+= TN[12];
		XMM0	 = _mm_add_ps(XMM0, XMM1);
		TN[14]	+= TN[13];
		XMM5	 = _mm_add_ps(XMM5, XMM0);
		TN[15]	+= TN[14];
		TXXYY[12]	 = XMM7;
		TXXYY[13]	 = XMM1;
		TXXYY[14]	 = XMM0;
		TXXYY[15]	 = XMM5;
		TN		+= 16;
		TXXYY	+= 16;
	}
	for(i=0;i<p->midpoint1_4;i+=4)
	{
		__m128	XMM0, XMM1, XMM4, XMM3;
		__m128x	TN, TN1;
		int	p0, p1, p2, p3;
		p0	 =-sb[i*2+1];
		p1	 =-sb[i*2+3];
		p2	 =-sb[i*2+5];
		p3	 =-sb[i*2+7];

		XMM0	 = XXYY[p0];
		XMM1	 = XXYY[p1];
		XMM4	 = XXYY[p2];
		XMM3	 = XXYY[p3];

		TN.sf[0]	 = N[p0];
		TN.sf[1]	 = N[p1];
		TN.sf[2]	 = N[p2];
		TN.sf[3]	 = N[p3];

		XMM0	 = _mm_xor_ps(XMM0, PM128(PCS_RNNR));
		XMM1	 = _mm_xor_ps(XMM1, PM128(PCS_RNNR));
		XMM4	 = _mm_xor_ps(XMM4, PM128(PCS_RNNR));
		XMM3	 = _mm_xor_ps(XMM3, PM128(PCS_RNNR));

		p0	 = sb[i*2  ];
		p1	 = sb[i*2+2];
		p2	 = sb[i*2+4];
		p3	 = sb[i*2+6];

		XMM0	 = _mm_add_ps(XMM0, XXYY[p0]);
		XMM1	 = _mm_add_ps(XMM1, XXYY[p1]);
		XMM4	 = _mm_add_ps(XMM4, XXYY[p2]);
		XMM3	 = _mm_add_ps(XMM3, XXYY[p3]);

		TN1.sf[0]	 = N[p0];
		TN1.sf[1]	 = N[p1];
		TN1.sf[2]	 = N[p2];
		TN1.sf[3]	 = N[p3];

		TN.ps	 = _mm_add_ps(TN.ps, TN1.ps);

		bark_noise_hybridmp_SSE_SUBC();
		XMM4	 = _mm_max_ps(XMM4, PM128(PFV_0));
		XMM4	 = _mm_sub_ps(XMM4, OFFSET);
		_mm_store_ps(noise+i  , XMM4);
	}
	if(p->midpoint2-i<4)
	{
		x	 = (float)i;
		for (;i<p->midpoint1;i++,x+=1.f)
		{
			lo	 = sb[i*2+1];
			hi	 = sb[i*2];

			tN	 = N[hi] + N[-lo];
			tX	 = xxyy[hi*4  ] - xxyy[-lo*4  ];
			tXX	 = xxyy[hi*4+1] + xxyy[-lo*4+1];
			tY	 = xxyy[hi*4+2] + xxyy[-lo*4+2];
			tXY	 = xxyy[hi*4+3] - xxyy[-lo*4+3];

			A	 = tY * tXX - tX * tXY;
			B	 = tN * tXY - tX * tY;
			D	 = tN * tXX - tX * tX;
			R	 = (A + x * B) / D;
			if(R<0.f)
				R	 = 0.f;

			noise[i]	 = R - offset;
		}
		for (;i<p->midpoint2;i++,x+=1.f)
		{
			lo	 = sb[i*2+1];
			hi	 = sb[i*2];

			tN	 = N[hi] - N[lo];
			tX	 = xxyy[hi*4  ] - xxyy[lo*4  ];
			tXX	 = xxyy[hi*4+1] - xxyy[lo*4+1];
			tY	 = xxyy[hi*4+2] - xxyy[lo*4+2];
			tXY	 = xxyy[hi*4+3] - xxyy[lo*4+3];

			A	 = tY * tXX - tX * tXY;
			B	 = tN * tXY - tX * tY;
			D	 = tN * tXX - tX * tX;
			R	 = (A + x * B) / D;
			if(R<0.f)
				R	 = 0.f;
			noise[i]	 = R - offset;
		}
		j	 = (i+3)&(~3);
		j	 = (j>=n)?n:j;
		for (;i<j;i++,x+=1.f)
		{
			R	 = (A + x * B) / D;
			if(R<0.f)
				R	 = 0.f;

			noise[i]	 = R - offset;
		}
		PA	 = _mm_set_ps1(A);
		PB	 = _mm_set_ps1(B);
		PD	 = _mm_set_ps1(1.f/D);
	}
	else
	{
		switch(p->midpoint1%4)
		{
			case 0:
				break;
			case 1:
				{
					__m128	XMM0, XMM1, XMM4, XMM3;
					__m128x	TN, TN1;
					int	p0, p1, p2, p3;
					p0	 =-sb[i*2+1];
					p1	 = sb[i*2+2];
					p2	 = sb[i*2+4];
					p3	 = sb[i*2+6];

					XMM0	 = XXYY[p0];
					XMM1	 = XXYY[p1];
					XMM4	 = XXYY[p2];
					XMM3	 = XXYY[p3];

					TN.sf[0]	 = N[p0];
					TN.sf[1]	 = N[p1];
					TN.sf[2]	 = N[p2];
					TN.sf[3]	 = N[p3];

					XMM0	 = _mm_xor_ps(XMM0, PM128(PCS_RNNR));

					p0	 = sb[i*2  ];
					p1	 = sb[i*2+3];
					p2	 = sb[i*2+5];
					p3	 = sb[i*2+7];

					XMM0	 = _mm_add_ps(XMM0, XXYY[p0]);
					XMM1	 = _mm_sub_ps(XMM1, XXYY[p1]);
					XMM4	 = _mm_sub_ps(XMM4, XXYY[p2]);
					XMM3	 = _mm_sub_ps(XMM3, XXYY[p3]);

					TN1.sf[0]	 = N[p0];
					TN1.sf[1]	 = N[p1];
					TN1.sf[2]	 = N[p2];
					TN1.sf[3]	 = N[p3];

					TN.ps	 = _mm_sub_ps(TN.ps, _mm_xor_ps(TN1.ps, PM128(PCS_NNNR)));

					bark_noise_hybridmp_SSE_SUBC();
					XMM4	 = _mm_max_ps(XMM4, PM128(PFV_0));
					XMM4	 = _mm_sub_ps(XMM4, OFFSET);
					_mm_store_ps(noise+i  , XMM4);
					i	+= 4;
				}
				break;
			case 2:
				{
					__m128	XMM0, XMM1, XMM4, XMM3;
					__m128x	TN, TN1;
					int	p0, p1, p2, p3;
					p0	 =-sb[i*2+1];
					p1	 =-sb[i*2+3];
					p2	 = sb[i*2+4];
					p3	 = sb[i*2+6];

					XMM0	 = XXYY[p0];
					XMM1	 = XXYY[p1];
					XMM4	 = XXYY[p2];
					XMM3	 = XXYY[p3];

					TN.sf[0]	 = N[p0];
					TN.sf[1]	 = N[p1];
					TN.sf[2]	 = N[p2];
					TN.sf[3]	 = N[p3];

					XMM0	 = _mm_xor_ps(XMM0, PM128(PCS_RNNR));
					XMM1	 = _mm_xor_ps(XMM1, PM128(PCS_RNNR));

					p0	 = sb[i*2  ];
					p1	 = sb[i*2+2];
					p2	 = sb[i*2+5];
					p3	 = sb[i*2+7];

					XMM0	 = _mm_add_ps(XMM0, XXYY[p0]);
					XMM1	 = _mm_add_ps(XMM1, XXYY[p1]);
					XMM4	 = _mm_sub_ps(XMM4, XXYY[p2]);
					XMM3	 = _mm_sub_ps(XMM3, XXYY[p3]);

					TN1.sf[0]	 = N[p0];
					TN1.sf[1]	 = N[p1];
					TN1.sf[2]	 = N[p2];
					TN1.sf[3]	 = N[p3];

					TN.ps	 = _mm_sub_ps(TN.ps, _mm_xor_ps(TN1.ps, PM128(PCS_NNRR)));

					bark_noise_hybridmp_SSE_SUBC();
					XMM4	 = _mm_max_ps(XMM4, PM128(PFV_0));
					XMM4	 = _mm_sub_ps(XMM4, OFFSET);
					_mm_store_ps(noise+i  , XMM4);
					i	+= 4;
				}
				break;
			case 3:
				{
					__m128	XMM0, XMM1, XMM4, XMM3;
					__m128x	TN, TN1;
					int	p0, p1, p2, p3;
					p0	 =-sb[i*2+1];
					p1	 =-sb[i*2+3];
					p2	 =-sb[i*2+5];
					p3	 = sb[i*2+6];

					XMM0	 = XXYY[p0];
					XMM1	 = XXYY[p1];
					XMM4	 = XXYY[p2];
					XMM3	 = XXYY[p3];

					TN.sf[0]	 = N[p0];
					TN.sf[1]	 = N[p1];
					TN.sf[2]	 = N[p2];
					TN.sf[3]	 = N[p3];

					XMM0	 = _mm_xor_ps(XMM0, PM128(PCS_RNNR));
					XMM1	 = _mm_xor_ps(XMM1, PM128(PCS_RNNR));
					XMM4	 = _mm_xor_ps(XMM4, PM128(PCS_RNNR));

					p0	 = sb[i*2  ];
					p1	 = sb[i*2+2];
					p2	 = sb[i*2+4];
					p3	 = sb[i*2+7];

					XMM0	 = _mm_add_ps(XMM0, XXYY[p0]);
					XMM1	 = _mm_add_ps(XMM1, XXYY[p1]);
					XMM4	 = _mm_add_ps(XMM4, XXYY[p2]);
					XMM3	 = _mm_sub_ps(XMM3, XXYY[p3]);

					TN1.sf[0]	 = N[p0];
					TN1.sf[1]	 = N[p1];
					TN1.sf[2]	 = N[p2];
					TN1.sf[3]	 = N[p3];

					TN.ps	 = _mm_sub_ps(TN.ps, _mm_xor_ps(TN1.ps, PM128(PCS_NRRR)));

					bark_noise_hybridmp_SSE_SUBC();
					XMM4	 = _mm_max_ps(XMM4, PM128(PFV_0));
					XMM4	 = _mm_sub_ps(XMM4, OFFSET);
					_mm_store_ps(noise+i  , XMM4);
					i	+= 4;
				}
				break;
		}
		for(;i<p->midpoint2_16;i+=16)
		{
			register __m128	XMM0, XMM1, XMM2, XMM3;
			register __m128	XMM4, XMM5, XMM6, XMM7;
			__m128x	TN0, TN1, TN2;
			int	p0, p1, p2, p3;
			p0	 = sb[i*2   ];
			p1	 = sb[i*2+ 2];
			p2	 = sb[i*2+ 4];
			p3	 = sb[i*2+ 6];
			XMM0	 = XXYY[p0];
			XMM1	 = XXYY[p1];
			XMM4	 = XXYY[p2];
			XMM3	 = XXYY[p3];
			TN0.sf[0]	 = N[p0];
			TN0.sf[1]	 = N[p1];
			TN0.sf[2]	 = N[p2];
			TN0.sf[3]	 = N[p3];
			p0	 = sb[i*2+ 1];
			p1	 = sb[i*2+ 3];
			p2	 = sb[i*2+ 5];
			p3	 = sb[i*2+ 7];
			XMM2	 = XXYY[p0];
			XMM5	 = XXYY[p1];
			XMM6	 = XXYY[p2];
			XMM7	 = XXYY[p3];
			XMM0	 = _mm_sub_ps(XMM0, XMM2);
			XMM1	 = _mm_sub_ps(XMM1, XMM5);
			XMM4	 = _mm_sub_ps(XMM4, XMM6);
			XMM3	 = _mm_sub_ps(XMM3, XMM7);
			TN1.sf[0]	 = N[p0];
			TN1.sf[1]	 = N[p1];
			TN1.sf[2]	 = N[p2];
			TN1.sf[3]	 = N[p3];
			XMM2	 = XMM0;
			XMM5	 = XMM4;
			XMM0	 = _mm_shuffle_ps(XMM0, XMM1, _MM_SHUFFLE(1,0,1,0));
			XMM2	 = _mm_shuffle_ps(XMM2, XMM1, _MM_SHUFFLE(3,2,3,2));
			XMM7	 = TN0.ps;
			XMM6	 = TN1.ps;
			XMM4	 = _mm_shuffle_ps(XMM4, XMM3, _MM_SHUFFLE(1,0,1,0));
			XMM5	 = _mm_shuffle_ps(XMM5, XMM3, _MM_SHUFFLE(3,2,3,2));
			p0	 = sb[i*2+ 8];
			p1	 = sb[i*2+10];
			XMM1	 = XMM0;
			XMM3	 = XMM2;
			XMM0	 = _mm_shuffle_ps(XMM0, XMM4, _MM_SHUFFLE(2,0,2,0));
			XMM1	 = _mm_shuffle_ps(XMM1, XMM4, _MM_SHUFFLE(3,1,3,1));
			XMM7	 = _mm_sub_ps(XMM7, XMM6);
			p2	 = sb[i*2+12];
			XMM2	 = _mm_shuffle_ps(XMM2, XMM5, _MM_SHUFFLE(2,0,2,0));
			XMM3	 = _mm_shuffle_ps(XMM3, XMM5, _MM_SHUFFLE(3,1,3,1));
			TN0.ps	 = XMM7;
			p3	 = sb[i*2+14];
			XMM4	 = XMM2;
			XMM5	 = XMM0;
			XMM6	 = XMM3;
			XMM7	 = XMM0;
			XMM4	 = _mm_mul_ps(XMM4, XMM1);
			XMM5	 = _mm_mul_ps(XMM5, XMM3);
			XMM3	 = TN0.ps;
			XMM6	 = _mm_mul_ps(XMM6, XMM3);
			XMM1	 = _mm_mul_ps(XMM1, XMM3);
			XMM3	 = _mm_load_ps(findex+i   );
			XMM7	 = _mm_mul_ps(XMM7, XMM2);
			XMM2	 = XXYY[p0];
			XMM0	 = _mm_mul_ps(XMM0, XMM0);
			XMM4	 = _mm_sub_ps(XMM4, XMM5);
			XMM5	 = XXYY[p1];
			XMM6	 = _mm_sub_ps(XMM6, XMM7);
			XMM7	 = XXYY[p2];
			XMM1	 = _mm_sub_ps(XMM1, XMM0);
			XMM0	 = XXYY[p3];
			XMM6	 = _mm_mul_ps(XMM6, XMM3);
			XMM3	 = _mm_rcp_ps(XMM1);
			TN0.sf[0]	 = N[p0];
			TN0.sf[1]	 = N[p1];
			XMM4	 = _mm_add_ps(XMM4, XMM6);
			XMM1	 = _mm_mul_ps(XMM1, XMM3);
			TN0.sf[2]	 = N[p2];
			TN0.sf[3]	 = N[p3];
			XMM1	 = _mm_mul_ps(XMM1, XMM3);
			p0	 = sb[i*2+ 9];
			p1	 = sb[i*2+11];
			XMM3	 = _mm_add_ps(XMM3, XMM3);
			p2	 = sb[i*2+13];
			p3	 = sb[i*2+15];
			XMM3	 = _mm_sub_ps(XMM3, XMM1);
			XMM1	 = _mm_load_ps(PFV_0);
			XMM6	 = XXYY[p0];
			XMM4	 = _mm_mul_ps(XMM4, XMM3);
			XMM3	 = OFFSET;
			XMM4	 = _mm_max_ps(XMM4, XMM1);
			XMM1	 = XXYY[p1];
			XMM4	 = _mm_sub_ps(XMM4, XMM3);
			XMM3	 = XXYY[p2];
			_mm_store_ps(noise+i   , XMM4);
			XMM4	 = XXYY[p3];
			XMM2	 = _mm_sub_ps(XMM2, XMM6);
			XMM5	 = _mm_sub_ps(XMM5, XMM1);
			XMM7	 = _mm_sub_ps(XMM7, XMM3);
			XMM0	 = _mm_sub_ps(XMM0, XMM4);
			TN1.sf[0]	 = N[p0];
			TN1.sf[1]	 = N[p1];
			TN1.sf[2]	 = N[p2];
			TN1.sf[3]	 = N[p3];
			XMM6	 = XMM2;
			XMM1	 = XMM7;
			XMM2	 = _mm_shuffle_ps(XMM2, XMM5, _MM_SHUFFLE(1,0,1,0));
			XMM6	 = _mm_shuffle_ps(XMM6, XMM5, _MM_SHUFFLE(3,2,3,2));
			XMM4	 = TN0.ps;
			XMM3	 = TN1.ps;
			XMM7	 = _mm_shuffle_ps(XMM7, XMM0, _MM_SHUFFLE(1,0,1,0));
			XMM1	 = _mm_shuffle_ps(XMM1, XMM0, _MM_SHUFFLE(3,2,3,2));
			p0	 = sb[i*2+16];
			p1	 = sb[i*2+18];
			XMM4	 = _mm_sub_ps(XMM4, XMM3);
			XMM5	 = XMM2;
			XMM0	 = XMM6;
			XMM2	 = _mm_shuffle_ps(XMM2, XMM7, _MM_SHUFFLE(2,0,2,0));
			XMM5	 = _mm_shuffle_ps(XMM5, XMM7, _MM_SHUFFLE(3,1,3,1));
			p2	 = sb[i*2+20];
			p3	 = sb[i*2+22];
			TN0.ps	 = XMM4;
			XMM6	 = _mm_shuffle_ps(XMM6, XMM1, _MM_SHUFFLE(2,0,2,0));
			XMM0	 = _mm_shuffle_ps(XMM0, XMM1, _MM_SHUFFLE(3,1,3,1));
			TN2.sf[0]	 = N[p0];
			TN2.sf[1]	 = N[p1];
			TN2.sf[2]	 = N[p2];
			TN2.sf[3]	 = N[p3];
			XMM7	 = XMM6;
			XMM1	 = XMM2;
			XMM3	 = XMM0;
			XMM4	 = XMM2;
			XMM7	 = _mm_mul_ps(XMM7, XMM5);
			XMM1	 = _mm_mul_ps(XMM1, XMM0);
			XMM0	 = TN0.ps;
			XMM3	 = _mm_mul_ps(XMM3, XMM0);
			XMM5	 = _mm_mul_ps(XMM5, XMM0);
			XMM0	 = _mm_load_ps(findex+i+ 4);
			XMM4	 = _mm_mul_ps(XMM4, XMM6);
			XMM6	 = XXYY[p0];
			XMM2	 = _mm_mul_ps(XMM2, XMM2);
			XMM7	 = _mm_sub_ps(XMM7, XMM1);
			XMM1	 = XXYY[p1];
			XMM3	 = _mm_sub_ps(XMM3, XMM4);
			XMM4	 = XXYY[p2];
			XMM5	 = _mm_sub_ps(XMM5, XMM2);
			XMM2	 = XXYY[p3];
			XMM3	 = _mm_mul_ps(XMM3, XMM0);
			XMM0	 = _mm_rcp_ps(XMM5);
			p0	 = sb[i*2+17];
			p1	 = sb[i*2+19];
			XMM7	 = _mm_add_ps(XMM7, XMM3);
			XMM3	 = XXYY[p0];
			XMM5	 = _mm_mul_ps(XMM5, XMM0);
			p2	 = sb[i*2+21];
			p3	 = sb[i*2+23];
			XMM5	 = _mm_mul_ps(XMM5, XMM0);
			XMM0	 = _mm_add_ps(XMM0, XMM0);
			TN1.sf[0]	 = N[p0];
			XMM0	 = _mm_sub_ps(XMM0, XMM5);
			XMM5	 = _mm_load_ps(PFV_0);
			XMM7	 = _mm_mul_ps(XMM7, XMM0);
			TN1.sf[1]	 = N[p1];
			XMM0	 = OFFSET;
			XMM7	 = _mm_max_ps(XMM7, XMM5);
			TN1.sf[2]	 = N[p2];
			XMM5	 = XXYY[p1];
			XMM7	 = _mm_sub_ps(XMM7, XMM0);
			TN1.sf[3]	 = N[p3];
			XMM0	 = XXYY[p2];
			_mm_store_ps(noise+i+ 4, XMM7);
			XMM7	 = XXYY[p3];
			XMM6	 = _mm_sub_ps(XMM6, XMM3);
			XMM1	 = _mm_sub_ps(XMM1, XMM5);
			XMM4	 = _mm_sub_ps(XMM4, XMM0);
			XMM2	 = _mm_sub_ps(XMM2, XMM7);
			XMM3	 = XMM6;
			XMM5	 = XMM4;
			XMM6	 = _mm_shuffle_ps(XMM6, XMM1, _MM_SHUFFLE(1,0,1,0));
			XMM3	 = _mm_shuffle_ps(XMM3, XMM1, _MM_SHUFFLE(3,2,3,2));
			XMM7	 = TN2.ps;
			XMM0	 = TN1.ps;
			XMM4	 = _mm_shuffle_ps(XMM4, XMM2, _MM_SHUFFLE(1,0,1,0));
			XMM5	 = _mm_shuffle_ps(XMM5, XMM2, _MM_SHUFFLE(3,2,3,2));
			p0	 = sb[i*2+24];
			p1	 = sb[i*2+26];
			XMM1	 = XMM6;
			XMM2	 = XMM3;
			XMM6	 = _mm_shuffle_ps(XMM6, XMM4, _MM_SHUFFLE(2,0,2,0));
			XMM1	 = _mm_shuffle_ps(XMM1, XMM4, _MM_SHUFFLE(3,1,3,1));
			XMM7	 = _mm_sub_ps(XMM7, XMM0);
			p2	 = sb[i*2+28];
			XMM3	 = _mm_shuffle_ps(XMM3, XMM5, _MM_SHUFFLE(2,0,2,0));
			XMM2	 = _mm_shuffle_ps(XMM2, XMM5, _MM_SHUFFLE(3,1,3,1));
			TN0.ps	 = XMM7;
			p3	 = sb[i*2+30];
			XMM4	 = XMM3;
			XMM5	 = XMM6;
			XMM0	 = XMM2;
			XMM7	 = XMM6;
			XMM4	 = _mm_mul_ps(XMM4, XMM1);
			XMM5	 = _mm_mul_ps(XMM5, XMM2);
			XMM2	 = TN0.ps;
			XMM0	 = _mm_mul_ps(XMM0, XMM2);
			XMM1	 = _mm_mul_ps(XMM1, XMM2);
			XMM2	 = _mm_load_ps(findex+i+ 8);
			XMM7	 = _mm_mul_ps(XMM7, XMM3);
			XMM3	 = XXYY[p0];
			XMM6	 = _mm_mul_ps(XMM6, XMM6);
			XMM4	 = _mm_sub_ps(XMM4, XMM5);
			XMM5	 = XXYY[p1];
			XMM0	 = _mm_sub_ps(XMM0, XMM7);
			XMM7	 = XXYY[p2];
			XMM1	 = _mm_sub_ps(XMM1, XMM6);
			XMM6	 = XXYY[p3];
			XMM0	 = _mm_mul_ps(XMM0, XMM2);
			XMM2	 = _mm_rcp_ps(XMM1);
			TN0.sf[0]	 = N[p0];
			TN0.sf[1]	 = N[p1];
			XMM4	 = _mm_add_ps(XMM4, XMM0);
			XMM1	 = _mm_mul_ps(XMM1, XMM2);
			TN0.sf[2]	 = N[p2];
			TN0.sf[3]	 = N[p3];
			XMM1	 = _mm_mul_ps(XMM1, XMM2);
			p0	 = sb[i*2+25];
			p1	 = sb[i*2+27];
			XMM2	 = _mm_add_ps(XMM2, XMM2);
			p2	 = sb[i*2+29];
			p3	 = sb[i*2+31];
			XMM2	 = _mm_sub_ps(XMM2, XMM1);
			XMM1	 = _mm_load_ps(PFV_0);
			XMM0	 = XXYY[p0];
			XMM4	 = _mm_mul_ps(XMM4, XMM2);
			XMM2	 = OFFSET;
			XMM4	 = _mm_max_ps(XMM4, XMM1);
			XMM1	 = XXYY[p1];
			XMM4	 = _mm_sub_ps(XMM4, XMM2);
			XMM2	 = XXYY[p2];
			_mm_store_ps(noise+i+ 8, XMM4);
			XMM4	 = XXYY[p3];
			XMM3	 = _mm_sub_ps(XMM3, XMM0);
			XMM5	 = _mm_sub_ps(XMM5, XMM1);
			XMM7	 = _mm_sub_ps(XMM7, XMM2);
			XMM6	 = _mm_sub_ps(XMM6, XMM4);
			TN1.sf[0]	 = N[p0];
			TN1.sf[1]	 = N[p1];
			TN1.sf[2]	 = N[p2];
			TN1.sf[3]	 = N[p3];
			XMM0	 = XMM3;
			XMM1	 = XMM7;
			XMM3	 = _mm_shuffle_ps(XMM3, XMM5, _MM_SHUFFLE(1,0,1,0));
			XMM0	 = _mm_shuffle_ps(XMM0, XMM5, _MM_SHUFFLE(3,2,3,2));
			XMM4	 = TN0.ps;
			XMM2	 = TN1.ps;
			XMM7	 = _mm_shuffle_ps(XMM7, XMM6, _MM_SHUFFLE(1,0,1,0));
			XMM1	 = _mm_shuffle_ps(XMM1, XMM6, _MM_SHUFFLE(3,2,3,2));
			XMM4	 = _mm_sub_ps(XMM4, XMM2);
			XMM5	 = XMM3;
			XMM6	 = XMM0;
			XMM3	 = _mm_shuffle_ps(XMM3, XMM7, _MM_SHUFFLE(2,0,2,0));
			XMM5	 = _mm_shuffle_ps(XMM5, XMM7, _MM_SHUFFLE(3,1,3,1));
			TN0.ps	 = XMM4;
			XMM0	 = _mm_shuffle_ps(XMM0, XMM1, _MM_SHUFFLE(2,0,2,0));
			XMM6	 = _mm_shuffle_ps(XMM6, XMM1, _MM_SHUFFLE(3,1,3,1));
			XMM7	 = XMM0;
			XMM1	 = XMM3;
			XMM2	 = XMM6;
			XMM4	 = XMM3;
			XMM7	 = _mm_mul_ps(XMM7, XMM5);
			XMM1	 = _mm_mul_ps(XMM1, XMM6);
			XMM6	 = TN0.ps;
			XMM2	 = _mm_mul_ps(XMM2, XMM6);
			XMM5	 = _mm_mul_ps(XMM5, XMM6);
			XMM6	 = _mm_load_ps(findex+i+12);
			XMM4	 = _mm_mul_ps(XMM4, XMM0);
			XMM3	 = _mm_mul_ps(XMM3, XMM3);
			XMM7	 = _mm_sub_ps(XMM7, XMM1);
			XMM2	 = _mm_sub_ps(XMM2, XMM4);
			XMM5	 = _mm_sub_ps(XMM5, XMM3);
			XMM2	 = _mm_mul_ps(XMM2, XMM6);
			XMM6	 = _mm_rcp_ps(XMM5);
			XMM7	 = _mm_add_ps(XMM7, XMM2);
			XMM5	 = _mm_mul_ps(XMM5, XMM6);
			XMM5	 = _mm_mul_ps(XMM5, XMM6);
			XMM6	 = _mm_add_ps(XMM6, XMM6);
			XMM6	 = _mm_sub_ps(XMM6, XMM5);
			XMM5	 = _mm_load_ps(PFV_0);
			XMM7	 = _mm_mul_ps(XMM7, XMM6);
			XMM6	 = OFFSET;
			XMM7	 = _mm_max_ps(XMM7, XMM5);
			XMM7	 = _mm_sub_ps(XMM7, XMM6);
			_mm_store_ps(noise+i+12, XMM7);
		}
		for(;i<p->midpoint2_8;i+=8)
		{
			register __m128	XMM0, XMM1, XMM2, XMM3;
			register __m128	XMM4, XMM5, XMM6, XMM7;
			__m128x	TN0, TN1;
			int	p0, p1, p2, p3;
			p0	 = sb[i*2   ];
			p1	 = sb[i*2+ 2];
			p2	 = sb[i*2+ 4];
			p3	 = sb[i*2+ 6];
			XMM0	 = XXYY[p0];
			XMM1	 = XXYY[p1];
			XMM4	 = XXYY[p2];
			XMM3	 = XXYY[p3];
			TN0.sf[0]	 = N[p0];
			TN0.sf[1]	 = N[p1];
			TN0.sf[2]	 = N[p2];
			TN0.sf[3]	 = N[p3];
			p0	 = sb[i*2+ 1];
			p1	 = sb[i*2+ 3];
			p2	 = sb[i*2+ 5];
			p3	 = sb[i*2+ 7];
			XMM2	 = XXYY[p0];
			XMM5	 = XXYY[p1];
			XMM6	 = XXYY[p2];
			XMM7	 = XXYY[p3];
			XMM0	 = _mm_sub_ps(XMM0, XMM2);
			XMM1	 = _mm_sub_ps(XMM1, XMM5);
			XMM4	 = _mm_sub_ps(XMM4, XMM6);
			XMM3	 = _mm_sub_ps(XMM3, XMM7);
			TN1.sf[0]	 = N[p0];
			TN1.sf[1]	 = N[p1];
			TN1.sf[2]	 = N[p2];
			TN1.sf[3]	 = N[p3];
			XMM2	 = XMM0;
			XMM5	 = XMM4;
			XMM0	 = _mm_shuffle_ps(XMM0, XMM1, _MM_SHUFFLE(1,0,1,0));
			XMM2	 = _mm_shuffle_ps(XMM2, XMM1, _MM_SHUFFLE(3,2,3,2));
			XMM7	 = TN0.ps;
			XMM6	 = TN1.ps;
			XMM4	 = _mm_shuffle_ps(XMM4, XMM3, _MM_SHUFFLE(1,0,1,0));
			XMM5	 = _mm_shuffle_ps(XMM5, XMM3, _MM_SHUFFLE(3,2,3,2));
			p0	 = sb[i*2+ 8];
			p1	 = sb[i*2+10];
			XMM1	 = XMM0;
			XMM3	 = XMM2;
			XMM0	 = _mm_shuffle_ps(XMM0, XMM4, _MM_SHUFFLE(2,0,2,0));
			XMM1	 = _mm_shuffle_ps(XMM1, XMM4, _MM_SHUFFLE(3,1,3,1));
			XMM7	 = _mm_sub_ps(XMM7, XMM6);
			p2	 = sb[i*2+12];
			XMM2	 = _mm_shuffle_ps(XMM2, XMM5, _MM_SHUFFLE(2,0,2,0));
			XMM3	 = _mm_shuffle_ps(XMM3, XMM5, _MM_SHUFFLE(3,1,3,1));
			TN0.ps	 = XMM7;
			p3	 = sb[i*2+14];
			XMM4	 = XMM2;
			XMM5	 = XMM0;
			XMM6	 = XMM3;
			XMM7	 = XMM0;
			XMM4	 = _mm_mul_ps(XMM4, XMM1);
			XMM5	 = _mm_mul_ps(XMM5, XMM3);
			XMM3	 = TN0.ps;
			XMM6	 = _mm_mul_ps(XMM6, XMM3);
			XMM1	 = _mm_mul_ps(XMM1, XMM3);
			XMM3	 = _mm_load_ps(findex+i   );
			XMM7	 = _mm_mul_ps(XMM7, XMM2);
			XMM2	 = XXYY[p0];
			XMM0	 = _mm_mul_ps(XMM0, XMM0);
			XMM4	 = _mm_sub_ps(XMM4, XMM5);
			XMM5	 = XXYY[p1];
			XMM6	 = _mm_sub_ps(XMM6, XMM7);
			XMM7	 = XXYY[p2];
			XMM1	 = _mm_sub_ps(XMM1, XMM0);
			XMM0	 = XXYY[p3];
			XMM6	 = _mm_mul_ps(XMM6, XMM3);
			XMM3	 = _mm_rcp_ps(XMM1);
			TN0.sf[0]	 = N[p0];
			TN0.sf[1]	 = N[p1];
			XMM4	 = _mm_add_ps(XMM4, XMM6);
			XMM1	 = _mm_mul_ps(XMM1, XMM3);
			TN0.sf[2]	 = N[p2];
			TN0.sf[3]	 = N[p3];
			XMM1	 = _mm_mul_ps(XMM1, XMM3);
			p0	 = sb[i*2+ 9];
			p1	 = sb[i*2+11];
			XMM3	 = _mm_add_ps(XMM3, XMM3);
			p2	 = sb[i*2+13];
			p3	 = sb[i*2+15];
			XMM3	 = _mm_sub_ps(XMM3, XMM1);
			XMM1	 = _mm_load_ps(PFV_0);
			XMM6	 = XXYY[p0];
			XMM4	 = _mm_mul_ps(XMM4, XMM3);
			XMM3	 = OFFSET;
			XMM4	 = _mm_max_ps(XMM4, XMM1);
			XMM1	 = XXYY[p1];
			XMM4	 = _mm_sub_ps(XMM4, XMM3);
			XMM3	 = XXYY[p2];
			_mm_store_ps(noise+i   , XMM4);
			XMM4	 = XXYY[p3];
			XMM2	 = _mm_sub_ps(XMM2, XMM6);
			XMM5	 = _mm_sub_ps(XMM5, XMM1);
			XMM7	 = _mm_sub_ps(XMM7, XMM3);
			XMM0	 = _mm_sub_ps(XMM0, XMM4);
			TN1.sf[0]	 = N[p0];
			TN1.sf[1]	 = N[p1];
			TN1.sf[2]	 = N[p2];
			TN1.sf[3]	 = N[p3];
			XMM6	 = XMM2;
			XMM1	 = XMM7;
			XMM2	 = _mm_shuffle_ps(XMM2, XMM5, _MM_SHUFFLE(1,0,1,0));
			XMM6	 = _mm_shuffle_ps(XMM6, XMM5, _MM_SHUFFLE(3,2,3,2));
			XMM4	 = TN0.ps;
			XMM3	 = TN1.ps;
			XMM7	 = _mm_shuffle_ps(XMM7, XMM0, _MM_SHUFFLE(1,0,1,0));
			XMM1	 = _mm_shuffle_ps(XMM1, XMM0, _MM_SHUFFLE(3,2,3,2));
			XMM4	 = _mm_sub_ps(XMM4, XMM3);
			XMM5	 = XMM2;
			XMM0	 = XMM6;
			XMM2	 = _mm_shuffle_ps(XMM2, XMM7, _MM_SHUFFLE(2,0,2,0));
			XMM5	 = _mm_shuffle_ps(XMM5, XMM7, _MM_SHUFFLE(3,1,3,1));
			TN0.ps	 = XMM4;
			XMM6	 = _mm_shuffle_ps(XMM6, XMM1, _MM_SHUFFLE(2,0,2,0));
			XMM0	 = _mm_shuffle_ps(XMM0, XMM1, _MM_SHUFFLE(3,1,3,1));
			XMM7	 = XMM6;
			XMM1	 = XMM2;
			XMM3	 = XMM0;
			XMM4	 = XMM2;
			XMM7	 = _mm_mul_ps(XMM7, XMM5);
			XMM1	 = _mm_mul_ps(XMM1, XMM0);
			XMM0	 = TN0.ps;
			XMM3	 = _mm_mul_ps(XMM3, XMM0);
			XMM5	 = _mm_mul_ps(XMM5, XMM0);
			XMM0	 = _mm_load_ps(findex+i+ 4);
			XMM4	 = _mm_mul_ps(XMM4, XMM6);
			XMM2	 = _mm_mul_ps(XMM2, XMM2);
			XMM7	 = _mm_sub_ps(XMM7, XMM1);
			XMM3	 = _mm_sub_ps(XMM3, XMM4);
			XMM5	 = _mm_sub_ps(XMM5, XMM2);
			XMM3	 = _mm_mul_ps(XMM3, XMM0);
			XMM0	 = _mm_rcp_ps(XMM5);
			XMM7	 = _mm_add_ps(XMM7, XMM3);
			XMM5	 = _mm_mul_ps(XMM5, XMM0);
			XMM5	 = _mm_mul_ps(XMM5, XMM0);
			XMM0	 = _mm_add_ps(XMM0, XMM0);
			XMM0	 = _mm_sub_ps(XMM0, XMM5);
			XMM5	 = _mm_load_ps(PFV_0);
			XMM7	 = _mm_mul_ps(XMM7, XMM0);
			XMM0	 = OFFSET;
			XMM7	 = _mm_max_ps(XMM7, XMM5);
			XMM7	 = _mm_sub_ps(XMM7, XMM0);
			_mm_store_ps(noise+i+ 4, XMM7);
		}
		for(;i<p->midpoint2_4;i+=4)
		{
			register __m128	XMM0, XMM1, XMM2, XMM3;
			register __m128	XMM4, XMM5, XMM6, XMM7;
			__m128x	TN0, TN1;
			int	p0, p1, p2, p3;
			p0	 = sb[i*2   ];
			p1	 = sb[i*2+ 2];
			p2	 = sb[i*2+ 4];
			p3	 = sb[i*2+ 6];

			XMM0	 = XXYY[p0];
			XMM1	 = XXYY[p1];
			XMM4	 = XXYY[p2];
			XMM3	 = XXYY[p3];

			TN0.sf[0]	 = N[p0];
			TN0.sf[1]	 = N[p1];
			TN0.sf[2]	 = N[p2];
			TN0.sf[3]	 = N[p3];

			p0	 = sb[i*2+ 1];
			p1	 = sb[i*2+ 3];
			p2	 = sb[i*2+ 5];
			p3	 = sb[i*2+ 7];

			XMM2	 = XXYY[p0];
			XMM5	 = XXYY[p1];
			XMM6	 = XXYY[p2];
			XMM7	 = XXYY[p3];

			XMM0	 = _mm_sub_ps(XMM0, XMM2);
			XMM1	 = _mm_sub_ps(XMM1, XMM5);
			XMM4	 = _mm_sub_ps(XMM4, XMM6);
			XMM3	 = _mm_sub_ps(XMM3, XMM7);

			XMM2	 = XMM0;
			XMM5	 = XMM4;
			XMM0	 = _mm_shuffle_ps(XMM0, XMM1, _MM_SHUFFLE(1,0,1,0));
			XMM2	 = _mm_shuffle_ps(XMM2, XMM1, _MM_SHUFFLE(3,2,3,2));
			TN1.sf[0]	 = N[p0];
			TN1.sf[1]	 = N[p1];
			XMM7	 = TN0.ps;
			XMM4	 = _mm_shuffle_ps(XMM4, XMM3, _MM_SHUFFLE(1,0,1,0));
			XMM5	 = _mm_shuffle_ps(XMM5, XMM3, _MM_SHUFFLE(3,2,3,2));
			TN1.sf[2]	 = N[p2];
			TN1.sf[3]	 = N[p3];
			XMM1	 = XMM0;
			XMM3	 = XMM2;
			XMM6	 = TN1.ps;
			XMM0	 = _mm_shuffle_ps(XMM0, XMM4, _MM_SHUFFLE(2,0,2,0));
			XMM1	 = _mm_shuffle_ps(XMM1, XMM4, _MM_SHUFFLE(3,1,3,1));
			XMM7	 = _mm_sub_ps(XMM7, XMM6);
			XMM2	 = _mm_shuffle_ps(XMM2, XMM5, _MM_SHUFFLE(2,0,2,0));
			XMM3	 = _mm_shuffle_ps(XMM3, XMM5, _MM_SHUFFLE(3,1,3,1));
			TN0.ps	 = XMM7;
			XMM4	 = XMM2;
			XMM5	 = XMM0;
			XMM6	 = XMM3;
			XMM7	 = XMM0;
			XMM4	 = _mm_mul_ps(XMM4, XMM1);
			XMM5	 = _mm_mul_ps(XMM5, XMM3);
			XMM3	 = TN0.ps;
			XMM6	 = _mm_mul_ps(XMM6, XMM3);
			XMM1	 = _mm_mul_ps(XMM1, XMM3);
			XMM3	 = _mm_load_ps(findex+i   );
			XMM7	 = _mm_mul_ps(XMM7, XMM2);
			XMM0	 = _mm_mul_ps(XMM0, XMM0);
			XMM4	 = _mm_sub_ps(XMM4, XMM5);
			XMM6	 = _mm_sub_ps(XMM6, XMM7);
			XMM1	 = _mm_sub_ps(XMM1, XMM0);
			XMM6	 = _mm_mul_ps(XMM6, XMM3);
			XMM3	 = _mm_rcp_ps(XMM1);
			XMM4	 = _mm_add_ps(XMM4, XMM6);
			XMM1	 = _mm_mul_ps(XMM1, XMM3);
			XMM1	 = _mm_mul_ps(XMM1, XMM3);
			XMM3	 = _mm_add_ps(XMM3, XMM3);
			XMM3	 = _mm_sub_ps(XMM3, XMM1);
			XMM1	 = _mm_load_ps(PFV_0);
			XMM4	 = _mm_mul_ps(XMM4, XMM3);
			XMM3	 = OFFSET;
			XMM4	 = _mm_max_ps(XMM4, XMM1);
			XMM4	 = _mm_sub_ps(XMM4, XMM3);
			_mm_store_ps(noise+i   , XMM4);
		}
		if(i!=n)
		{
			__m128	XMM0, XMM1, XMM4, XMM3;
			__m128x	TN, TN1;
			int	p0, p1, p2;
			switch(p->midpoint2%4)
			{
				case 0:
					{
						lo	 = sb[i*2-1];
						hi	 = sb[i*2-2];

						tN	 = N[hi] - N[lo];
						tX	 = xxyy[hi*4  ] - xxyy[lo*4  ];
						tXX	 = xxyy[hi*4+1] - xxyy[lo*4+1];
						tY	 = xxyy[hi*4+2] - xxyy[lo*4+2];
						tXY	 = xxyy[hi*4+3] - xxyy[lo*4+3];

						A	 = tY * tXX - tX * tXY;
						B	 = tN * tXY - tX * tY;
						D	 = tN * tXX - tX * tX;
						PA	 = _mm_set_ps1(A);
						PB	 = _mm_set_ps1(B);
						PD	 = _mm_set_ps1(1.f/D);
					}
					break;
				case 1:
					{
						p0	 = sb[i*2  ];

						XMM0	 = XXYY[p0];

						TN.ps	 = _mm_set_ps1(N[p0]);

						p0	 = sb[i*2+1];

						XMM1	 =
						XMM4	 =
						XMM3	 =
						XMM0	 = _mm_sub_ps(XMM0, XXYY[p0]);

						TN1.ps	 = _mm_set_ps1(N[p0]);

						TN.ps	 = _mm_sub_ps(TN.ps, TN1.ps);

						bark_noise_hybridmp_SSE_SUBC2();
						XMM4	 = _mm_max_ps(XMM4, PM128(PFV_0));
						XMM4	 = _mm_sub_ps(XMM4, OFFSET);
						_mm_store_ps(noise+i  , XMM4);
						i	+= 4;
						PA		 = _mm_shuffle_ps(PA, PA, _MM_SHUFFLE(0,0,0,0));
						PB		 = _mm_shuffle_ps(PB, PB, _MM_SHUFFLE(0,0,0,0));
						PD		 = _mm_shuffle_ps(PD, PD, _MM_SHUFFLE(0,0,0,0));
					}
					break;
				case 2:
					{
						p0	 = sb[i*2  ];
						p1	 = sb[i*2+2];

						XMM0	 = XXYY[p0];
						XMM1	 = XXYY[p1];

						TN.sf[0]	 = N[p0];
						TN.sf[1]	 =
						TN.sf[2]	 =
						TN.sf[3]	 = N[p1];

						p0	 = sb[i*2+1];
						p1	 = sb[i*2+3];

						XMM0	 = _mm_sub_ps(XMM0, XXYY[p0]);
						XMM4	 =
						XMM3	 =
						XMM1	 = _mm_sub_ps(XMM1, XXYY[p1]);

						TN1.sf[0]	 = N[p0];
						TN1.sf[1]	 =
						TN1.sf[2]	 =
						TN1.sf[3]	 = N[p1];

						TN.ps	 = _mm_sub_ps(TN.ps, TN1.ps);

						bark_noise_hybridmp_SSE_SUBC2();
						XMM4	 = _mm_max_ps(XMM4, PM128(PFV_0));
						XMM4	 = _mm_sub_ps(XMM4, OFFSET);
						_mm_store_ps(noise+i  , XMM4);
						i	+= 4;
						PA		 = _mm_shuffle_ps(PA, PA, _MM_SHUFFLE(1,1,1,1));
						PB		 = _mm_shuffle_ps(PB, PB, _MM_SHUFFLE(1,1,1,1));
						PD		 = _mm_shuffle_ps(PD, PD, _MM_SHUFFLE(1,1,1,1));
					}
					break;
				case 3:
					{
						p0	 = sb[i*2  ];
						p1	 = sb[i*2+2];
						p2	 = sb[i*2+4];

						XMM0	 = XXYY[p0];
						XMM1	 = XXYY[p1];
						XMM4	 = XXYY[p2];

						TN.sf[0]	 = N[p0];
						TN.sf[1]	 = N[p1];
						TN.sf[2]	 =
						TN.sf[3]	 = N[p2];

						p0	 = sb[i*2+1];
						p1	 = sb[i*2+3];
						p2	 = sb[i*2+5];

						XMM0	 = _mm_sub_ps(XMM0, XXYY[p0]);
						XMM1	 = _mm_sub_ps(XMM1, XXYY[p1]);
						XMM3	 =
						XMM4	 = _mm_sub_ps(XMM4, XXYY[p2]);

						TN1.sf[0]	 = N[p0];
						TN1.sf[1]	 = N[p1];
						TN1.sf[2]	 =
						TN1.sf[3]	 = N[p2];

						TN.ps	 = _mm_sub_ps(TN.ps, TN1.ps);

						bark_noise_hybridmp_SSE_SUBC2();
						XMM4	 = _mm_max_ps(XMM4, PM128(PFV_0));
						XMM4	 = _mm_sub_ps(XMM4, OFFSET);
						_mm_store_ps(noise+i  , XMM4);
						i	+= 4;
						PA		 = _mm_shuffle_ps(PA, PA, _MM_SHUFFLE(2,2,2,2));
						PB		 = _mm_shuffle_ps(PB, PB, _MM_SHUFFLE(2,2,2,2));
						PD		 = _mm_shuffle_ps(PD, PD, _MM_SHUFFLE(2,2,2,2));
					}
					break;
			}
		}
	}
	if(i<n)
	{
		__m128	XMM0	 = PA;
		__m128	XMM1	 = PB;
		__m128	XMM2	 = _mm_set_ps1(-offset);
		XMM0	 = _mm_mul_ps(XMM0, PD);
		XMM1	 = _mm_mul_ps(XMM1, PD);
		XMM0	 = _mm_sub_ps(XMM0, OFFSET);
		if(i%8!=0)
		{
			__m128	XMM4	 = _mm_load_ps(findex+i   );
			XMM4	 = _mm_mul_ps(XMM4, XMM1);
			XMM4	 = _mm_add_ps(XMM4, XMM0);
			XMM4	 = _mm_max_ps(XMM4, XMM2);
			_mm_store_ps(noise+i  , XMM4);
			i	+= 4;
		}
		if(i%16!=0)
		{
			__m128	XMM4	 = _mm_load_ps(findex+i   );
			__m128	XMM5	 = _mm_load_ps(findex+i+ 4);
			XMM4	 = _mm_mul_ps(XMM4, XMM1);
			XMM5	 = _mm_mul_ps(XMM5, XMM1);
			XMM4	 = _mm_add_ps(XMM4, XMM0);
			XMM5	 = _mm_add_ps(XMM5, XMM0);
			XMM4	 = _mm_max_ps(XMM4, XMM2);
			XMM5	 = _mm_max_ps(XMM5, XMM2);
			_mm_store_ps(noise+i  , XMM4);
			_mm_store_ps(noise+i+4, XMM5);
			i	+= 8;
		}
		for(;i<n;i+=16)
		{
			__m128	XMM4	 = _mm_load_ps(findex+i   );
			__m128	XMM5	 = _mm_load_ps(findex+i+ 4);
			__m128	XMM6	 = _mm_load_ps(findex+i+ 8);
			__m128	XMM7	 = _mm_load_ps(findex+i+12);
			XMM4	 = _mm_mul_ps(XMM4, XMM1);
			XMM5	 = _mm_mul_ps(XMM5, XMM1);
			XMM6	 = _mm_mul_ps(XMM6, XMM1);
			XMM7	 = _mm_mul_ps(XMM7, XMM1);
			XMM4	 = _mm_add_ps(XMM4, XMM0);
			XMM5	 = _mm_add_ps(XMM5, XMM0);
			XMM6	 = _mm_add_ps(XMM6, XMM0);
			XMM7	 = _mm_add_ps(XMM7, XMM0);
			XMM4	 = _mm_max_ps(XMM4, XMM2);
			XMM5	 = _mm_max_ps(XMM5, XMM2);
			XMM6	 = _mm_max_ps(XMM6, XMM2);
			XMM7	 = _mm_max_ps(XMM7, XMM2);
			_mm_store_ps(noise+i   , XMM4);
			_mm_store_ps(noise+i+ 4, XMM5);
			_mm_store_ps(noise+i+ 8, XMM6);
			_mm_store_ps(noise+i+12, XMM7);
		}
	}

	if (fixed <= 0) return;

	midpoint1	 = (fixed+1)/2;
	midpoint2	 = n-fixed/2;

	j	 = midpoint1&(~7);
	p1	 = fixed / 2;
	p0	 = p1 - 3;

	for(i=0;i<j;i+=8)
	{
		__m128	XMM0, XMM1, XMM2, XMM3;
		__m128	XMM4, XMM5, XMM6, XMM7;
		__m128x	TN, TN1;

		XMM5	 = _mm_lddqu_ps(N+p0);
		XMM0	 = XXYY[p0+3];
		XMM1	 = XXYY[p0+2];
		XMM4	 = XXYY[p0+1];
		XMM3	 = XXYY[p0  ];
		TN.ps	 = _mm_shuffle_ps(XMM5, XMM5, _MM_SHUFFLE(0,1,2,3));
		XMM0	 = _mm_xor_ps(XMM0, PM128(PCS_RNNR));
		XMM1	 = _mm_xor_ps(XMM1, PM128(PCS_RNNR));
		XMM4	 = _mm_xor_ps(XMM4, PM128(PCS_RNNR));
		XMM3	 = _mm_xor_ps(XMM3, PM128(PCS_RNNR));
		XMM5	 = _mm_lddqu_ps(N+p1);
		XMM0	 = _mm_add_ps(XMM0, XXYY[p1  ]);
		XMM1	 = _mm_add_ps(XMM1, XXYY[p1+1]);
		XMM4	 = _mm_add_ps(XMM4, XXYY[p1+2]);
		XMM3	 = _mm_add_ps(XMM3, XXYY[p1+3]);
		TN.ps	 = _mm_add_ps(TN.ps, XMM5);
		XMM2 = XMM0;
		XMM5 = XMM4;
		XMM0	 = _mm_shuffle_ps(XMM0, XMM1, _MM_SHUFFLE(1,0,1,0));
		XMM2	 = _mm_shuffle_ps(XMM2, XMM1, _MM_SHUFFLE(3,2,3,2));
		XMM4	 = _mm_shuffle_ps(XMM4, XMM3, _MM_SHUFFLE(1,0,1,0));
		XMM5	 = _mm_shuffle_ps(XMM5, XMM3, _MM_SHUFFLE(3,2,3,2));
		XMM1 = XMM0;
		XMM3 = XMM2;
		XMM0	 = _mm_shuffle_ps(XMM0, XMM4, _MM_SHUFFLE(2,0,2,0));
		XMM1	 = _mm_shuffle_ps(XMM1, XMM4, _MM_SHUFFLE(3,1,3,1));
		XMM2	 = _mm_shuffle_ps(XMM2, XMM5, _MM_SHUFFLE(2,0,2,0));
		XMM3	 = _mm_shuffle_ps(XMM3, XMM5, _MM_SHUFFLE(3,1,3,1));
		XMM4 = XMM2;
		XMM5 = XMM0;
		XMM6 = XMM3;
		XMM7 = XMM0;
		XMM4 = _mm_mul_ps(XMM4, XMM1);
		XMM5 = _mm_mul_ps(XMM5, XMM3);
		XMM3 = _mm_load_ps(findex+i);
		XMM6 = _mm_mul_ps(XMM6, TN.ps);
		XMM1 = _mm_mul_ps(XMM1, TN.ps);
		XMM7 = _mm_mul_ps(XMM7, XMM2);
		XMM2	 = _mm_lddqu_ps(N+p0-4);
		XMM0 = _mm_mul_ps(XMM0, XMM0);
		XMM4 = _mm_sub_ps(XMM4, XMM5);
		XMM5	 = XXYY[p0-1];
		XMM6 = _mm_sub_ps(XMM6, XMM7);
		XMM7	 = XXYY[p0-2];
		XMM1 = _mm_sub_ps(XMM1, XMM0);
		XMM0	 = XXYY[p0-3];
		XMM6 = _mm_mul_ps(XMM6, XMM3);
		XMM3 = _mm_rcp_ps(XMM1);
		XMM4 = _mm_add_ps(XMM4, XMM6);
		XMM6	 = XXYY[p0-4];
		XMM1 = _mm_mul_ps(XMM1, XMM3);
		TN1.ps	 = _mm_shuffle_ps(XMM2, XMM2, _MM_SHUFFLE(0,1,2,3));
		XMM1 = _mm_mul_ps(XMM1, XMM3);
		XMM5	 = _mm_xor_ps(XMM5, PM128(PCS_RNNR));
		XMM3 = _mm_add_ps(XMM3, XMM3);
		XMM7	 = _mm_xor_ps(XMM7, PM128(PCS_RNNR));
		XMM3 = _mm_sub_ps(XMM3, XMM1);
		XMM0	 = _mm_xor_ps(XMM0, PM128(PCS_RNNR));
		XMM4 = _mm_mul_ps(XMM4, XMM3);
		XMM6	 = _mm_xor_ps(XMM6, PM128(PCS_RNNR));
		XMM2	 = _mm_lddqu_ps(N+p1+4);
		XMM4	 = _mm_sub_ps(XMM4, OFFSET);
		XMM5	 = _mm_add_ps(XMM5, XXYY[p1+4]);
		XMM4	 = _mm_min_ps(XMM4, PM128(noise+i  ));
		XMM7	 = _mm_add_ps(XMM7, XXYY[p1+5]);
		XMM0	 = _mm_add_ps(XMM0, XXYY[p1+6]);
		_mm_store_ps(noise+i  , XMM4);
		XMM6	 = _mm_add_ps(XMM6, XXYY[p1+7]);
		TN1.ps	 = _mm_add_ps(TN1.ps, XMM2);
		XMM1 = XMM5;
		XMM2 = XMM0;
		XMM5	 = _mm_shuffle_ps(XMM5, XMM7, _MM_SHUFFLE(1,0,1,0));
		XMM1	 = _mm_shuffle_ps(XMM1, XMM7, _MM_SHUFFLE(3,2,3,2));
		XMM0	 = _mm_shuffle_ps(XMM0, XMM6, _MM_SHUFFLE(1,0,1,0));
		XMM2	 = _mm_shuffle_ps(XMM2, XMM6, _MM_SHUFFLE(3,2,3,2));
		XMM7 = XMM5;
		XMM6 = XMM1;
		XMM5	 = _mm_shuffle_ps(XMM5, XMM0, _MM_SHUFFLE(2,0,2,0));
		XMM7	 = _mm_shuffle_ps(XMM7, XMM0, _MM_SHUFFLE(3,1,3,1));
		XMM1	 = _mm_shuffle_ps(XMM1, XMM2, _MM_SHUFFLE(2,0,2,0));
		XMM6	 = _mm_shuffle_ps(XMM6, XMM2, _MM_SHUFFLE(3,1,3,1));
		XMM0 = XMM1;
		XMM2 = XMM5;
		XMM3 = XMM6;
		XMM4 = XMM5;
		XMM0 = _mm_mul_ps(XMM0, XMM7);
		XMM2 = _mm_mul_ps(XMM2, XMM6);
		XMM6 = _mm_load_ps(findex+i+4);
		XMM3 = _mm_mul_ps(XMM3, TN1.ps);
		XMM7 = _mm_mul_ps(XMM7, TN1.ps);
		XMM4 = _mm_mul_ps(XMM4, XMM1);
		XMM5 = _mm_mul_ps(XMM5, XMM5);
		XMM0 = _mm_sub_ps(XMM0, XMM2);
		XMM3 = _mm_sub_ps(XMM3, XMM4);
		XMM7 = _mm_sub_ps(XMM7, XMM5);
		XMM3 = _mm_mul_ps(XMM3, XMM6);
		XMM6 = _mm_rcp_ps(XMM7);
		XMM0 = _mm_add_ps(XMM0, XMM3);
		XMM7 = _mm_mul_ps(XMM7, XMM6);
		XMM7 = _mm_mul_ps(XMM7, XMM6);
		XMM6 = _mm_add_ps(XMM6, XMM6);
		XMM6 = _mm_sub_ps(XMM6, XMM7);
		XMM6 = _mm_mul_ps(XMM6, XMM0);
		XMM6	 = _mm_sub_ps(XMM6, OFFSET);
		XMM6	 = _mm_min_ps(XMM6, PM128(noise+i+4));
		_mm_store_ps(noise+i+4, XMM6);
		p0 -= 8;
		p1 += 8;
	}
	j	 = midpoint1&(~3);
	for(;i<j;i+=4)
	{
		__m128	XMM0, XMM1, XMM4, XMM3, XMM5;
		__m128x	TN;

		XMM5	 = _mm_lddqu_ps(N+p0);
		XMM0	 = XXYY[p0+3];
		XMM1	 = XXYY[p0+2];
		XMM4	 = XXYY[p0+1];
		XMM3	 = XXYY[p0  ];
		TN.ps	 = _mm_shuffle_ps(XMM5, XMM5, _MM_SHUFFLE(0,1,2,3));

		XMM0	 = _mm_xor_ps(XMM0, PM128(PCS_RNNR));
		XMM1	 = _mm_xor_ps(XMM1, PM128(PCS_RNNR));
		XMM4	 = _mm_xor_ps(XMM4, PM128(PCS_RNNR));
		XMM3	 = _mm_xor_ps(XMM3, PM128(PCS_RNNR));

		XMM5	 = _mm_lddqu_ps(N+p1);
		XMM0	 = _mm_add_ps(XMM0, XXYY[p1  ]);
		XMM1	 = _mm_add_ps(XMM1, XXYY[p1+1]);
		XMM4	 = _mm_add_ps(XMM4, XXYY[p1+2]);
		XMM3	 = _mm_add_ps(XMM3, XXYY[p1+3]);

		TN.ps	 = _mm_add_ps(TN.ps, XMM5);

		bark_noise_hybridmp_SSE_SUBC();
		XMM4	 = _mm_sub_ps(XMM4, OFFSET);
		XMM4	 = _mm_min_ps(XMM4, PM128(noise+i  ));
		_mm_store_ps(noise+i  , XMM4);
		p0 -= 4;
		p1 += 4;
	}
	if(midpoint2-i<4)
	{
		x	 = (float)i;
		for (;i<midpoint1;i++,x+=1.f)
		{
			hi	 = i + fixed / 2;
			lo	 = hi - fixed;

			tN	 = N[hi] + N[-lo];
			tX	 = xxyy[hi*4  ] - xxyy[-lo*4  ];
			tXX	 = xxyy[hi*4+1] + xxyy[-lo*4+1];
			tY	 = xxyy[hi*4+2] + xxyy[-lo*4+2];
			tXY	 = xxyy[hi*4+3] - xxyy[-lo*4+3];

			A	 = tY * tXX - tX * tXY;
			B	 = tN * tXY - tX * tY;
			D	 = tN * tXX - tX * tX;
			R	 = (A + x * B) / D;

			if(R - offset < noise[i])
				noise[i]	 = R - offset;
		}
		for (;i<midpoint2;i++,x+=1.f)
		{
			hi	 = i + fixed / 2;
			lo	 = hi - fixed;

			tN	 = N[hi] - N[lo];
			tX	 = xxyy[hi*4  ] - xxyy[lo*4  ];
			tXX	 = xxyy[hi*4+1] - xxyy[lo*4+1];
			tY	 = xxyy[hi*4+2] - xxyy[lo*4+2];
			tXY	 = xxyy[hi*4+3] - xxyy[lo*4+3];

			A	 = tY * tXX - tX * tXY;
			B	 = tN * tXY - tX * tY;
			D	 = tN * tXX - tX * tX;
			R	 = (A + x * B) / D;
			if(R - offset < noise[i])
				noise[i]	 = R - offset;
		}
		j	 = (i+3)&(~3);
		j	 = (j>=n)?n:j;
		for (;i<j;i++,x+=1.f)
		{
			R	 = (A + x * B) / D;
			if(R - offset < noise[i])
				noise[i]	 = R - offset;
		}
		PA	 = _mm_set_ps1(A);
		PB	 = _mm_set_ps1(B);
		PD	 = _mm_set_ps1(D);
	}
	else
	{
		switch(midpoint1%4)
		{
			case 0:
				break;
			case 1:
				{
					__m128	XMM0, XMM1, XMM4, XMM3;
					__m128x	TN, TN1;
					int	p0, p1;
					p0	 = -((i  ) + fixed / 2 - fixed);
					p1	 = (i+1) + fixed / 2;

					XMM0	 = XXYY[p0  ];
					XMM1	 = XXYY[p1  ];
					XMM4	 = XXYY[p1+1];
					XMM3	 = XXYY[p1+2];

					TN.sf[0]	 = N[p0  ];
					TN.sf[1]	 = N[p1  ];
					TN.sf[2]	 = N[p1+1];
					TN.sf[3]	 = N[p1+2];

					XMM0	 = _mm_xor_ps(XMM0, PM128(PCS_RNNR));

					p0	 = (i  ) + fixed / 2;
					p1	-= fixed;

					XMM0	 = _mm_add_ps(XMM0, XXYY[p0  ]);
					XMM1	 = _mm_sub_ps(XMM1, XXYY[p1  ]);
					XMM4	 = _mm_sub_ps(XMM4, XXYY[p1+1]);
					XMM3	 = _mm_sub_ps(XMM3, XXYY[p1+2]);

					TN1.sf[0]	 = N[p0  ];
					TN1.sf[1]	 = N[p1  ];
					TN1.sf[2]	 = N[p1+1];
					TN1.sf[3]	 = N[p1+2];

					TN.ps	 = _mm_sub_ps(TN.ps, _mm_xor_ps(TN1.ps, PM128(PCS_NNNR)));

					bark_noise_hybridmp_SSE_SUBC();
					XMM4	 = _mm_sub_ps(XMM4, OFFSET);
					XMM4	 = _mm_min_ps(XMM4, PM128(noise+i  ));
					_mm_store_ps(noise+i  , XMM4);
					i	+= 4;
				}
				break;
			case 2:
				{
					__m128	XMM0, XMM1, XMM4, XMM3;
					__m128x	TN, TN1;
					int	p0, p1;
					p0	 = -((i  ) + fixed / 2 - fixed);
					p1	 = (i+2) + fixed / 2;

					XMM0	 = XXYY[p0  ];
					XMM1	 = XXYY[p0-1];
					XMM4	 = XXYY[p1  ];
					XMM3	 = XXYY[p1+1];

					TN.sf[0]	 = N[p0  ];
					TN.sf[1]	 = N[p0-1];
					TN.sf[2]	 = N[p1  ];
					TN.sf[3]	 = N[p1+1];

					XMM0	 = _mm_xor_ps(XMM0, PM128(PCS_RNNR));
					XMM1	 = _mm_xor_ps(XMM1, PM128(PCS_RNNR));

					p0	 = (i  ) + fixed / 2;
					p1	-= fixed;

					XMM0	 = _mm_add_ps(XMM0, XXYY[p0  ]);
					XMM1	 = _mm_add_ps(XMM1, XXYY[p0+1]);
					XMM4	 = _mm_sub_ps(XMM4, XXYY[p1  ]);
					XMM3	 = _mm_sub_ps(XMM3, XXYY[p1+1]);

					TN1.sf[0]	 = N[p0  ];
					TN1.sf[1]	 = N[p0+1];
					TN1.sf[2]	 = N[p1  ];
					TN1.sf[3]	 = N[p1+1];

					TN.ps	 = _mm_sub_ps(TN.ps, _mm_xor_ps(TN1.ps, PM128(PCS_NNRR)));

					bark_noise_hybridmp_SSE_SUBC();
					XMM4	 = _mm_sub_ps(XMM4, OFFSET);
					XMM4	 = _mm_min_ps(XMM4, PM128(noise+i  ));
					_mm_store_ps(noise+i  , XMM4);
					i	+= 4;
				}
				break;
			case 3:
				{
					__m128	XMM0, XMM1, XMM4, XMM3;
					__m128x	TN, TN1;
					int	p0, p1;
					p0	 = -((i  ) + fixed / 2 - fixed);
					p1	 = (i+3) + fixed / 2;

					XMM0	 = XXYY[p0  ];
					XMM1	 = XXYY[p0-1];
					XMM4	 = XXYY[p0-2];
					XMM3	 = XXYY[p1  ];

					TN.sf[0]	 = N[p0  ];
					TN.sf[1]	 = N[p0-1];
					TN.sf[2]	 = N[p0-2];
					TN.sf[3]	 = N[p1  ];

					XMM0	 = _mm_xor_ps(XMM0, PM128(PCS_RNNR));
					XMM1	 = _mm_xor_ps(XMM1, PM128(PCS_RNNR));
					XMM4	 = _mm_xor_ps(XMM4, PM128(PCS_RNNR));

					p0	 = (i  ) + fixed / 2;
					p1	-= fixed;

					XMM0	 = _mm_add_ps(XMM0, XXYY[p0  ]);
					XMM1	 = _mm_add_ps(XMM1, XXYY[p0+1]);
					XMM4	 = _mm_sub_ps(XMM4, XXYY[p0+2]);
					XMM3	 = _mm_sub_ps(XMM3, XXYY[p1  ]);

					TN1.sf[0]	 = N[p0  ];
					TN1.sf[1]	 = N[p0+1];
					TN1.sf[2]	 = N[p0+2];
					TN1.sf[3]	 = N[p1  ];

					TN.ps	 = _mm_sub_ps(TN.ps, _mm_xor_ps(TN1.ps, PM128(PCS_NRRR)));

					bark_noise_hybridmp_SSE_SUBC();
					XMM4	 = _mm_sub_ps(XMM4, OFFSET);
					XMM4	 = _mm_min_ps(XMM4, PM128(noise+i  ));
					_mm_store_ps(noise+i  , XMM4);
					i	+= 4;
				}
				break;
		}
		p0	 = i  + fixed / 2;
		p1	 = p0 - fixed;
		j	 = ((midpoint2-i)&(~15))+i;
		for(;i<j;i+=16)
		{
			__m128	XMM0, XMM1, XMM2, XMM3;
			__m128	XMM4, XMM5, XMM6, XMM7;
			__m128x	TN, TN1;

			XMM0	 = XXYY[p0   ];
			XMM1	 = XXYY[p0+ 1];
			XMM4	 = XXYY[p0+ 2];
			XMM3	 = XXYY[p0+ 3];
			TN.ps	 = _mm_lddqu_ps(N+p0   );
			XMM5	 = _mm_lddqu_ps(N+p1   );
			XMM0	 = _mm_sub_ps(XMM0, XXYY[p1   ]);
			XMM1	 = _mm_sub_ps(XMM1, XXYY[p1+ 1]);
			XMM4	 = _mm_sub_ps(XMM4, XXYY[p1+ 2]);
			XMM3	 = _mm_sub_ps(XMM3, XXYY[p1+ 3]);
			TN.ps	 = _mm_sub_ps(TN.ps, XMM5);
			XMM2 = XMM0;
			XMM5 = XMM4;
			XMM0	 = _mm_shuffle_ps(XMM0, XMM1, _MM_SHUFFLE(1,0,1,0));
			XMM2	 = _mm_shuffle_ps(XMM2, XMM1, _MM_SHUFFLE(3,2,3,2));
			XMM4	 = _mm_shuffle_ps(XMM4, XMM3, _MM_SHUFFLE(1,0,1,0));
			XMM5	 = _mm_shuffle_ps(XMM5, XMM3, _MM_SHUFFLE(3,2,3,2));
			XMM1 = XMM0;
			XMM3 = XMM2;
			XMM0	 = _mm_shuffle_ps(XMM0, XMM4, _MM_SHUFFLE(2,0,2,0));
			XMM1	 = _mm_shuffle_ps(XMM1, XMM4, _MM_SHUFFLE(3,1,3,1));
			XMM2	 = _mm_shuffle_ps(XMM2, XMM5, _MM_SHUFFLE(2,0,2,0));
			XMM3	 = _mm_shuffle_ps(XMM3, XMM5, _MM_SHUFFLE(3,1,3,1));
			XMM4 = XMM2;
			XMM5 = XMM0;
			XMM6 = XMM3;
			XMM7 = XMM0;
			XMM4 = _mm_mul_ps(XMM4, XMM1);
			XMM5 = _mm_mul_ps(XMM5, XMM3);
			XMM3 = _mm_load_ps(findex+i   );
			XMM6 = _mm_mul_ps(XMM6, TN.ps);
			XMM1 = _mm_mul_ps(XMM1, TN.ps);
			XMM7 = _mm_mul_ps(XMM7, XMM2);
			XMM2	 = XXYY[p0+ 4];
			XMM0 = _mm_mul_ps(XMM0, XMM0);
			XMM4 = _mm_sub_ps(XMM4, XMM5);
			XMM5	 = XXYY[p0+ 5];
			XMM6 = _mm_sub_ps(XMM6, XMM7);
			XMM7	 = XXYY[p0+ 6];
			XMM1 = _mm_sub_ps(XMM1, XMM0);
			XMM0	 = XXYY[p0+ 7];
			XMM6 = _mm_mul_ps(XMM6, XMM3);

			TN1.ps	 = _mm_lddqu_ps(N+p0+ 4);
			XMM3 = _mm_rcp_ps(XMM1);
			XMM4 = _mm_add_ps(XMM4, XMM6);
			XMM6	 = _mm_lddqu_ps(N+p1+ 4);
			XMM1 = _mm_mul_ps(XMM1, XMM3);
			XMM2	 = _mm_sub_ps(XMM2, XXYY[p1+ 4]);
			XMM1 = _mm_mul_ps(XMM1, XMM3);
			XMM5	 = _mm_sub_ps(XMM5, XXYY[p1+ 5]);
			XMM3 = _mm_add_ps(XMM3, XMM3);
			XMM7	 = _mm_sub_ps(XMM7, XXYY[p1+ 6]);
			XMM3 = _mm_sub_ps(XMM3, XMM1);
			XMM0	 = _mm_sub_ps(XMM0, XXYY[p1+ 7]);
			XMM4 = _mm_mul_ps(XMM4, XMM3);
			TN1.ps	 = _mm_sub_ps(TN1.ps, XMM6);
			XMM4	 = _mm_sub_ps(XMM4, OFFSET);
			XMM1 = XMM2;
			XMM4	 = _mm_min_ps(XMM4, PM128(noise+i   ));
			XMM6 = XMM7;
			_mm_store_ps(noise+i   , XMM4);
			XMM2	 = _mm_shuffle_ps(XMM2, XMM5, _MM_SHUFFLE(1,0,1,0));
			XMM1	 = _mm_shuffle_ps(XMM1, XMM5, _MM_SHUFFLE(3,2,3,2));
			XMM7	 = _mm_shuffle_ps(XMM7, XMM0, _MM_SHUFFLE(1,0,1,0));
			XMM6	 = _mm_shuffle_ps(XMM6, XMM0, _MM_SHUFFLE(3,2,3,2));
			XMM5 = XMM2;
			XMM0 = XMM1;
			XMM2	 = _mm_shuffle_ps(XMM2, XMM7, _MM_SHUFFLE(2,0,2,0));
			XMM5	 = _mm_shuffle_ps(XMM5, XMM7, _MM_SHUFFLE(3,1,3,1));
			XMM1	 = _mm_shuffle_ps(XMM1, XMM6, _MM_SHUFFLE(2,0,2,0));
			XMM0	 = _mm_shuffle_ps(XMM0, XMM6, _MM_SHUFFLE(3,1,3,1));
			XMM7 = XMM1;
			XMM6 = XMM2;
			XMM3 = XMM0;
			XMM4 = XMM2;
			XMM7 = _mm_mul_ps(XMM7, XMM5);
			XMM6 = _mm_mul_ps(XMM6, XMM0);
			XMM0 = _mm_load_ps(findex+i+ 4);
			XMM3 = _mm_mul_ps(XMM3, TN1.ps);
			XMM5 = _mm_mul_ps(XMM5, TN1.ps);
			XMM4 = _mm_mul_ps(XMM4, XMM1);
			XMM1	 = XXYY[p0+ 8];
			XMM2 = _mm_mul_ps(XMM2, XMM2);
			XMM7 = _mm_sub_ps(XMM7, XMM6);
			XMM6	 = XXYY[p0+ 9];
			XMM3 = _mm_sub_ps(XMM3, XMM4);
			XMM4	 = XXYY[p0+10];
			XMM5 = _mm_sub_ps(XMM5, XMM2);
			XMM2	 = XXYY[p0+11];
			XMM3 = _mm_mul_ps(XMM3, XMM0);
			TN.ps	 = _mm_lddqu_ps(N+p0+ 8);
			XMM0 = _mm_rcp_ps(XMM5);
			XMM7 = _mm_add_ps(XMM7, XMM3);
			XMM3	 = _mm_lddqu_ps(N+p1+ 8);
			XMM5 = _mm_mul_ps(XMM5, XMM0);
			XMM1	 = _mm_sub_ps(XMM1, XXYY[p1+ 8]);
			XMM5 = _mm_mul_ps(XMM5, XMM0);
			XMM6	 = _mm_sub_ps(XMM6, XXYY[p1+ 9]);
			XMM0 = _mm_add_ps(XMM0, XMM0);
			XMM4	 = _mm_sub_ps(XMM4, XXYY[p1+10]);
			XMM0 = _mm_sub_ps(XMM0, XMM5);
			XMM2	 = _mm_sub_ps(XMM2, XXYY[p1+11]);
			XMM7 = _mm_mul_ps(XMM7, XMM0);
			TN.ps	 = _mm_sub_ps(TN.ps, XMM3);
			XMM7	 = _mm_sub_ps(XMM7, OFFSET);
			XMM5 = XMM1;
			XMM7	 = _mm_min_ps(XMM7, PM128(noise+i+ 4));
			XMM3 = XMM4;
			_mm_store_ps(noise+i+ 4, XMM7);
			XMM1	 = _mm_shuffle_ps(XMM1, XMM6, _MM_SHUFFLE(1,0,1,0));
			XMM5	 = _mm_shuffle_ps(XMM5, XMM6, _MM_SHUFFLE(3,2,3,2));
			XMM4	 = _mm_shuffle_ps(XMM4, XMM2, _MM_SHUFFLE(1,0,1,0));
			XMM3	 = _mm_shuffle_ps(XMM3, XMM2, _MM_SHUFFLE(3,2,3,2));
			XMM6 = XMM1;
			XMM2 = XMM5;
			XMM1	 = _mm_shuffle_ps(XMM1, XMM4, _MM_SHUFFLE(2,0,2,0));
			XMM6	 = _mm_shuffle_ps(XMM6, XMM4, _MM_SHUFFLE(3,1,3,1));
			XMM5	 = _mm_shuffle_ps(XMM5, XMM3, _MM_SHUFFLE(2,0,2,0));
			XMM2	 = _mm_shuffle_ps(XMM2, XMM3, _MM_SHUFFLE(3,1,3,1));
			XMM4 = XMM5;
			XMM3 = XMM1;
			XMM0 = XMM2;
			XMM7 = XMM1;
			XMM4 = _mm_mul_ps(XMM4, XMM6);
			XMM3 = _mm_mul_ps(XMM3, XMM2);
			XMM2 = _mm_load_ps(findex+i+ 8);
			XMM0 = _mm_mul_ps(XMM0, TN.ps);
			XMM6 = _mm_mul_ps(XMM6, TN.ps);
			XMM7 = _mm_mul_ps(XMM7, XMM5);
			XMM5	 = XXYY[p0+12];
			XMM1 = _mm_mul_ps(XMM1, XMM1);
			XMM4 = _mm_sub_ps(XMM4, XMM3);
			XMM3	 = XXYY[p0+13];
			XMM0 = _mm_sub_ps(XMM0, XMM7);
			XMM7	 = XXYY[p0+14];
			XMM6 = _mm_sub_ps(XMM6, XMM1);
			XMM1	 = XXYY[p0+15];
			XMM0 = _mm_mul_ps(XMM0, XMM2);
			TN1.ps	 = _mm_lddqu_ps(N+p0+12);
			XMM2 = _mm_rcp_ps(XMM6);
			XMM4 = _mm_add_ps(XMM4, XMM0);
			XMM0	 = _mm_lddqu_ps(N+p1+12);
			XMM6 = _mm_mul_ps(XMM6, XMM2);
			XMM5	 = _mm_sub_ps(XMM5, XXYY[p1+12]);
			XMM6 = _mm_mul_ps(XMM6, XMM2);
			XMM3	 = _mm_sub_ps(XMM3, XXYY[p1+13]);
			XMM2 = _mm_add_ps(XMM2, XMM2);
			XMM7	 = _mm_sub_ps(XMM7, XXYY[p1+14]);
			XMM2 = _mm_sub_ps(XMM2, XMM6);
			XMM1	 = _mm_sub_ps(XMM1, XXYY[p1+15]);
			XMM4 = _mm_mul_ps(XMM4, XMM2);
			TN1.ps	 = _mm_sub_ps(TN1.ps, XMM0);
			XMM4	 = _mm_sub_ps(XMM4, OFFSET);
			XMM6 = XMM5;
			XMM4	 = _mm_min_ps(XMM4, PM128(noise+i+ 8));
			XMM0 = XMM7;
			_mm_store_ps(noise+i+ 8, XMM4);
			XMM5	 = _mm_shuffle_ps(XMM5, XMM3, _MM_SHUFFLE(1,0,1,0));
			XMM6	 = _mm_shuffle_ps(XMM6, XMM3, _MM_SHUFFLE(3,2,3,2));
			XMM7	 = _mm_shuffle_ps(XMM7, XMM1, _MM_SHUFFLE(1,0,1,0));
			XMM0	 = _mm_shuffle_ps(XMM0, XMM1, _MM_SHUFFLE(3,2,3,2));
			XMM3 = XMM5;
			XMM1 = XMM6;
			XMM5	 = _mm_shuffle_ps(XMM5, XMM7, _MM_SHUFFLE(2,0,2,0));
			XMM3	 = _mm_shuffle_ps(XMM3, XMM7, _MM_SHUFFLE(3,1,3,1));
			XMM6	 = _mm_shuffle_ps(XMM6, XMM0, _MM_SHUFFLE(2,0,2,0));
			XMM1	 = _mm_shuffle_ps(XMM1, XMM0, _MM_SHUFFLE(3,1,3,1));
			XMM7 = XMM6;
			XMM0 = XMM5;
			XMM2 = XMM1;
			XMM4 = XMM5;
			XMM7 = _mm_mul_ps(XMM7, XMM3);
			XMM0 = _mm_mul_ps(XMM0, XMM1);
			XMM1 = _mm_load_ps(findex+i+12);
			XMM2 = _mm_mul_ps(XMM2, TN1.ps);
			XMM3 = _mm_mul_ps(XMM3, TN1.ps);
			XMM4 = _mm_mul_ps(XMM4, XMM6);
			XMM5 = _mm_mul_ps(XMM5, XMM5);
			XMM7 = _mm_sub_ps(XMM7, XMM0);
			XMM2 = _mm_sub_ps(XMM2, XMM4);
			XMM3 = _mm_sub_ps(XMM3, XMM5);
			XMM2 = _mm_mul_ps(XMM2, XMM1);
			XMM1 = _mm_rcp_ps(XMM3);
			XMM7 = _mm_add_ps(XMM7, XMM2);
			XMM3 = _mm_mul_ps(XMM3, XMM1);
			XMM3 = _mm_mul_ps(XMM3, XMM1);
			XMM1 = _mm_add_ps(XMM1, XMM1);
			XMM1 = _mm_sub_ps(XMM1, XMM3);
			XMM7 = _mm_mul_ps(XMM7, XMM1);
			XMM7	 = _mm_sub_ps(XMM7, OFFSET);
			XMM7	 = _mm_min_ps(XMM7, PM128(noise+i+12));
			_mm_store_ps(noise+i+12, XMM7);

			p0 += 16;
			p1 += 16;
		}
		j	 = ((midpoint2-i)&(~7))+i;
		for(;i<j;i+=8)
		{
			__m128	XMM0, XMM1, XMM2, XMM3;
			__m128	XMM4, XMM5, XMM6, XMM7;
			__m128x	TN, TN1;

			XMM0	 = XXYY[p0  ];
			XMM1	 = XXYY[p0+1];
			XMM4	 = XXYY[p0+2];
			XMM3	 = XXYY[p0+3];
			TN.ps	 = _mm_lddqu_ps(N+p0   );
			XMM5	 = _mm_lddqu_ps(N+p1   );
			XMM0	 = _mm_sub_ps(XMM0, XXYY[p1  ]);
			XMM1	 = _mm_sub_ps(XMM1, XXYY[p1+1]);
			XMM4	 = _mm_sub_ps(XMM4, XXYY[p1+2]);
			XMM3	 = _mm_sub_ps(XMM3, XXYY[p1+3]);
			TN.ps	 = _mm_sub_ps(TN.ps, XMM5);
			XMM2 = XMM0;
			XMM5 = XMM4;
			XMM0	 = _mm_shuffle_ps(XMM0, XMM1, _MM_SHUFFLE(1,0,1,0));
			XMM2	 = _mm_shuffle_ps(XMM2, XMM1, _MM_SHUFFLE(3,2,3,2));
			XMM4	 = _mm_shuffle_ps(XMM4, XMM3, _MM_SHUFFLE(1,0,1,0));
			XMM5	 = _mm_shuffle_ps(XMM5, XMM3, _MM_SHUFFLE(3,2,3,2));
			XMM1 = XMM0;
			XMM3 = XMM2;
			XMM0	 = _mm_shuffle_ps(XMM0, XMM4, _MM_SHUFFLE(2,0,2,0));
			XMM1	 = _mm_shuffle_ps(XMM1, XMM4, _MM_SHUFFLE(3,1,3,1));
			XMM2	 = _mm_shuffle_ps(XMM2, XMM5, _MM_SHUFFLE(2,0,2,0));
			XMM3	 = _mm_shuffle_ps(XMM3, XMM5, _MM_SHUFFLE(3,1,3,1));
			XMM4 = XMM2;
			XMM5 = XMM0;
			XMM6 = XMM3;
			XMM7 = XMM0;
			XMM4 = _mm_mul_ps(XMM4, XMM1);
			XMM5 = _mm_mul_ps(XMM5, XMM3);
			XMM3 = _mm_load_ps(findex+i  );
			XMM6 = _mm_mul_ps(XMM6, TN.ps);
			XMM1 = _mm_mul_ps(XMM1, TN.ps);
			XMM7 = _mm_mul_ps(XMM7, XMM2);
			XMM2	 = XXYY[p0+4];
			XMM0 = _mm_mul_ps(XMM0, XMM0);
			XMM4 = _mm_sub_ps(XMM4, XMM5);
			XMM5	 = XXYY[p0+5];
			XMM6 = _mm_sub_ps(XMM6, XMM7);
			XMM7	 = XXYY[p0+6];
			XMM1 = _mm_sub_ps(XMM1, XMM0);
			XMM0	 = XXYY[p0+7];
			XMM6 = _mm_mul_ps(XMM6, XMM3);
			TN1.ps	 = _mm_lddqu_ps(N+p0+ 4);
			XMM3 = _mm_rcp_ps(XMM1);
			XMM4 = _mm_add_ps(XMM4, XMM6);
			XMM6	 = _mm_lddqu_ps(N+p1+ 4);
			XMM1 = _mm_mul_ps(XMM1, XMM3);
			XMM2	 = _mm_sub_ps(XMM2, XXYY[p1+4]);
			XMM1 = _mm_mul_ps(XMM1, XMM3);
			XMM5	 = _mm_sub_ps(XMM5, XXYY[p1+5]);
			XMM3 = _mm_add_ps(XMM3, XMM3);
			XMM7	 = _mm_sub_ps(XMM7, XXYY[p1+6]);
			XMM3 = _mm_sub_ps(XMM3, XMM1);
			XMM0	 = _mm_sub_ps(XMM0, XXYY[p1+7]);
			XMM4 = _mm_mul_ps(XMM4, XMM3);
			TN1.ps	 = _mm_sub_ps(TN1.ps, XMM6);
			XMM4	 = _mm_sub_ps(XMM4, OFFSET);
			XMM1 = XMM2;
			XMM4	 = _mm_min_ps(XMM4, PM128(noise+i  ));
			XMM6 = XMM7;
			_mm_store_ps(noise+i  , XMM4);
			XMM2	 = _mm_shuffle_ps(XMM2, XMM5, _MM_SHUFFLE(1,0,1,0));
			XMM1	 = _mm_shuffle_ps(XMM1, XMM5, _MM_SHUFFLE(3,2,3,2));
			XMM7	 = _mm_shuffle_ps(XMM7, XMM0, _MM_SHUFFLE(1,0,1,0));
			XMM6	 = _mm_shuffle_ps(XMM6, XMM0, _MM_SHUFFLE(3,2,3,2));
			XMM5 = XMM2;
			XMM0 = XMM1;
			XMM2	 = _mm_shuffle_ps(XMM2, XMM7, _MM_SHUFFLE(2,0,2,0));
			XMM5	 = _mm_shuffle_ps(XMM5, XMM7, _MM_SHUFFLE(3,1,3,1));
			XMM1	 = _mm_shuffle_ps(XMM1, XMM6, _MM_SHUFFLE(2,0,2,0));
			XMM0	 = _mm_shuffle_ps(XMM0, XMM6, _MM_SHUFFLE(3,1,3,1));
			XMM7 = XMM1;
			XMM6 = XMM2;
			XMM3 = XMM0;
			XMM4 = XMM2;
			XMM7 = _mm_mul_ps(XMM7, XMM5);
			XMM6 = _mm_mul_ps(XMM6, XMM0);
			XMM0 = _mm_load_ps(findex+i+4);
			XMM3 = _mm_mul_ps(XMM3, TN1.ps);
			XMM5 = _mm_mul_ps(XMM5, TN1.ps);
			XMM4 = _mm_mul_ps(XMM4, XMM1);
			XMM2 = _mm_mul_ps(XMM2, XMM2);
			XMM7 = _mm_sub_ps(XMM7, XMM6);
			XMM3 = _mm_sub_ps(XMM3, XMM4);
			XMM5 = _mm_sub_ps(XMM5, XMM2);
			XMM3 = _mm_mul_ps(XMM3, XMM0);
			XMM0 = _mm_rcp_ps(XMM5);
			XMM7 = _mm_add_ps(XMM7, XMM3);
			XMM5 = _mm_mul_ps(XMM5, XMM0);
			XMM5 = _mm_mul_ps(XMM5, XMM0);
			XMM0 = _mm_add_ps(XMM0, XMM0);
			XMM0 = _mm_sub_ps(XMM0, XMM5);
			XMM7 = _mm_mul_ps(XMM7, XMM0);
			XMM7	 = _mm_sub_ps(XMM7, OFFSET);
			XMM7	 = _mm_min_ps(XMM7, PM128(noise+i+4));
			_mm_store_ps(noise+i+4, XMM7);

			p0 += 8;
			p1 += 8;
		}
		j	 = midpoint2&(~3);
		for(;i<j;i+=4)
		{
			__m128	XMM0, XMM1, XMM4, XMM3;
			__m128x	TN;
			__m128	XMM5;

			XMM0	 = XXYY[p0  ];
			XMM1	 = XXYY[p0+1];
			XMM4	 = XXYY[p0+2];
			XMM3	 = XXYY[p0+3];
			TN.ps	 = _mm_lddqu_ps(N+p0   );
			XMM5	 = _mm_lddqu_ps(N+p1   );
			XMM0	 = _mm_sub_ps(XMM0, XXYY[p1  ]);
			XMM1	 = _mm_sub_ps(XMM1, XXYY[p1+1]);
			XMM4	 = _mm_sub_ps(XMM4, XXYY[p1+2]);
			XMM3	 = _mm_sub_ps(XMM3, XXYY[p1+3]);

			TN.ps	 = _mm_sub_ps(TN.ps, XMM5);

			bark_noise_hybridmp_SSE_SUBC();
			XMM4	 = _mm_sub_ps(XMM4, OFFSET);
			XMM4	 = _mm_min_ps(XMM4, PM128(noise+i  ));
			_mm_store_ps(noise+i  , XMM4);
			p0 += 4;
			p1 += 4;
		}
		if(i!=n)
		{
			switch(midpoint2%4)
			{
				case 0:
					{
						hi	 = (i-1) + fixed / 2;
						lo	 = hi - fixed;

						tN	 = N[hi] - N[lo];
						tX	 = xxyy[hi*4  ] - xxyy[lo*4  ];
						tXX	 = xxyy[hi*4+1] - xxyy[lo*4+1];
						tY	 = xxyy[hi*4+2] - xxyy[lo*4+2];
						tXY	 = xxyy[hi*4+3] - xxyy[lo*4+3];

						A	 = tY * tXX - tX * tXY;
						B	 = tN * tXY - tX * tY;
						D	 = tN * tXX - tX * tX;
						PA	 = _mm_set_ps1(A);
						PB	 = _mm_set_ps1(B);
						PD	 = _mm_set_ps1(1.f/D);
					}
					break;
				case 1:
					{
						__m128	XMM0, XMM1, XMM4, XMM3;
						__m128x	TN, TN1;
						int p0	 = (i  ) + fixed / 2;

						XMM0	 =
						XMM1	 =
						XMM4	 =
						XMM3	 = XXYY[p0];

						TN.ps	 = _mm_set_ps1(N[p0]);

						p0	-= fixed;

						XMM0	 =
						XMM4	 =
						XMM3	 =
						XMM1	 = _mm_sub_ps(XMM3, XXYY[p0]);

						TN1.ps	 = _mm_set_ps1(N[p0]);

						TN.ps	 = _mm_sub_ps(TN.ps, TN1.ps);

						bark_noise_hybridmp_SSE_SUBC2();
						XMM4	 = _mm_sub_ps(XMM4, OFFSET);
						XMM4	 = _mm_min_ps(XMM4, PM128(noise+i  ));
						_mm_store_ps(noise+i  , XMM4);
						i	+= 4;
						PA		 = _mm_shuffle_ps(PA, PA, _MM_SHUFFLE(0,0,0,0));
						PB		 = _mm_shuffle_ps(PB, PB, _MM_SHUFFLE(0,0,0,0));
						PD		 = _mm_shuffle_ps(PD, PD, _MM_SHUFFLE(0,0,0,0));
					}
					break;
				case 2:
					{
						__m128	XMM0, XMM1, XMM4, XMM3;
						__m128x	TN;
						__m128	XMM5;
						int p0	 = (i  ) + fixed / 2;

						XMM5	 = _mm_lddqu_ps(N+p0);
						XMM0	 = XXYY[p0  ];
						XMM1	 =
						XMM4	 =
						XMM3	 = XXYY[p0+1];
						TN.ps	 = _mm_shuffle_ps(XMM5, XMM5, _MM_SHUFFLE(1,1,1,0));

						p0	-= fixed;

						XMM5	 = _mm_lddqu_ps(N+p0);
						XMM0	 = _mm_sub_ps(XMM0, XXYY[p0  ]);
						XMM4	 =
						XMM3	 =
						XMM1	 = _mm_sub_ps(XMM3, XXYY[p0+1]);
						XMM5	 = _mm_shuffle_ps(XMM5, XMM5, _MM_SHUFFLE(1,1,1,0));

						TN.ps	 = _mm_sub_ps(TN.ps, XMM5);

						bark_noise_hybridmp_SSE_SUBC2();
						XMM4	 = _mm_sub_ps(XMM4, OFFSET);
						XMM4	 = _mm_min_ps(XMM4, PM128(noise+i  ));
						_mm_store_ps(noise+i  , XMM4);
						i	+= 4;
						PA		 = _mm_shuffle_ps(PA, PA, _MM_SHUFFLE(1,1,1,1));
						PB		 = _mm_shuffle_ps(PB, PB, _MM_SHUFFLE(1,1,1,1));
						PD		 = _mm_shuffle_ps(PD, PD, _MM_SHUFFLE(1,1,1,1));
					}
					break;
				case 3:
					{
						__m128	XMM0, XMM1, XMM4, XMM3;
						__m128x	TN;
						__m128	XMM5;
						int p0	 = (i  ) + fixed / 2;

						XMM5	 = _mm_lddqu_ps(N+p0);
						XMM0	 = XXYY[p0  ];
						XMM1	 = XXYY[p0+1];
						XMM4	 =
						XMM3	 = XXYY[p0+2];
						TN.ps	 = _mm_shuffle_ps(XMM5, XMM5, _MM_SHUFFLE(2,2,1,0));

						p0	-=  fixed;

						XMM5	 = _mm_lddqu_ps(N+p0);
						XMM0	 = _mm_sub_ps(XMM0, XXYY[p0  ]);
						XMM1	 = _mm_sub_ps(XMM1, XXYY[p0+1]);
						XMM4	 =
						XMM3	 = _mm_sub_ps(XMM3, XXYY[p0+2]);
						XMM5	 = _mm_shuffle_ps(XMM5, XMM5, _MM_SHUFFLE(2,2,1,0));

						TN.ps	 = _mm_sub_ps(TN.ps, XMM5);

						bark_noise_hybridmp_SSE_SUBC2();
						XMM4	 = _mm_sub_ps(XMM4, OFFSET);
						XMM4	 = _mm_min_ps(XMM4, PM128(noise+i  ));
						_mm_store_ps(noise+i  , XMM4);
						i	+= 4;
						PA		 = _mm_shuffle_ps(PA, PA, _MM_SHUFFLE(2,2,2,2));
						PB		 = _mm_shuffle_ps(PB, PB, _MM_SHUFFLE(2,2,2,2));
						PD		 = _mm_shuffle_ps(PD, PD, _MM_SHUFFLE(2,2,2,2));
					}
					break;
			}
		}
	}
	if(i<n)
	{
		__m128	XMM0	 = PA;
		__m128	XMM1	 = PB;
		XMM0	 = _mm_mul_ps(XMM0, PD);
		XMM1	 = _mm_mul_ps(XMM1, PD);
		XMM0	 = _mm_sub_ps(XMM0, OFFSET);
		if(i%8!=0)
		{
			__m128	XMM4	 = _mm_load_ps(findex+i);
			XMM4	 = _mm_mul_ps(XMM4, XMM1);
			XMM4	 = _mm_add_ps(XMM4, XMM0);
			XMM4	 = _mm_min_ps(XMM4, PM128(noise+i   ));
			_mm_store_ps(noise+i   , XMM4);
			i	+= 4;
		}
		if(i%16!=0)
		{
			__m128	XMM4	 = _mm_load_ps(findex+i  );
			__m128	XMM5	 = _mm_load_ps(findex+i+4);
			__m128	XMM6	 = _mm_load_ps(noise+i   );
			__m128	XMM7	 = _mm_load_ps(noise+i+ 4);
			XMM4	 = _mm_mul_ps(XMM4, XMM1);
			XMM5	 = _mm_mul_ps(XMM5, XMM1);
			XMM4	 = _mm_add_ps(XMM4, XMM0);
			XMM5	 = _mm_add_ps(XMM5, XMM0);
			XMM6	 = _mm_min_ps(XMM6, XMM4);
			XMM7	 = _mm_min_ps(XMM7, XMM5);
			_mm_store_ps(noise+i   , XMM6);
			_mm_store_ps(noise+i+ 4, XMM7);
			i	+= 8;
		}
		for(;i<n;i+=32)
		{
			__m128	XMM2, XMM3, XMM4, XMM5, XMM6, XMM7;
			XMM4	 = _mm_load_ps(findex+i   );
			XMM5	 = _mm_load_ps(findex+i+ 4);
			XMM6	 = _mm_load_ps(noise+i    );
			XMM7	 = _mm_load_ps(noise+i+  4);
			XMM2	 = _mm_load_ps(findex+i+ 8);
			XMM3	 = _mm_load_ps(findex+i+12);
			XMM4	 = _mm_mul_ps(XMM4, XMM1);
			XMM5	 = _mm_mul_ps(XMM5, XMM1);
			XMM4	 = _mm_add_ps(XMM4, XMM0);
			XMM5	 = _mm_add_ps(XMM5, XMM0);
			XMM6	 = _mm_min_ps(XMM6, XMM4);
			XMM7	 = _mm_min_ps(XMM7, XMM5);
			XMM4	 = _mm_load_ps(noise+i+  8);
			XMM5	 = _mm_load_ps(noise+i+ 12);
			_mm_store_ps(noise+i   , XMM6);
			_mm_store_ps(noise+i+ 4, XMM7);
			XMM2	 = _mm_mul_ps(XMM2, XMM1);
			XMM3	 = _mm_mul_ps(XMM3, XMM1);
			XMM2	 = _mm_add_ps(XMM2, XMM0);
			XMM3	 = _mm_add_ps(XMM3, XMM0);
			XMM2	 = _mm_min_ps(XMM2, XMM4);
			XMM3	 = _mm_min_ps(XMM3, XMM5);
			_mm_store_ps(noise+i+ 8, XMM2);
			_mm_store_ps(noise+i+12, XMM3);
		}
	}
#else														/* SSE Optimize */
static void bark_noise_hybridmp(int n,const long *b,
                                const float *f,
                                float *noise,
                                const float offset,
                                const int fixed){

  float *N=alloca(n*sizeof(*N));
  float *X=alloca(n*sizeof(*N));
  float *XX=alloca(n*sizeof(*N));
  float *Y=alloca(n*sizeof(*N));
  float *XY=alloca(n*sizeof(*N));

  float tN, tX, tXX, tY, tXY;
  int i;

  int lo, hi;
  float R=0.f;
  float A=0.f;
  float B=0.f;
  float D=1.f;
  float w, x, y;

  tN = tX = tXX = tY = tXY = 0.f;

  y = f[0] + offset;
  if (y < 1.f) y = 1.f;

  w = y * y * .5;

  tN += w;
  tX += w;
  tY += w * y;

  N[0] = tN;
  X[0] = tX;
  XX[0] = tXX;
  Y[0] = tY;
  XY[0] = tXY;

  for (i = 1, x = 1.f; i < n; i++, x += 1.f) {

    y = f[i] + offset;
    if (y < 1.f) y = 1.f;

    w = y * y;

    tN += w;
    tX += w * x;
    tXX += w * x * x;
    tY += w * y;
    tXY += w * x * y;

    N[i] = tN;
    X[i] = tX;
    XX[i] = tXX;
    Y[i] = tY;
    XY[i] = tXY;
  }

  for (i = 0, x = 0.f; i < n; i++, x += 1.f) {

    lo = b[i] >> 16;
    hi = b[i] & 0xffff;
    if( lo>=0 || -lo>=n ) break;
    if( hi>=n ) break;

    tN = N[hi] + N[-lo];
    tX = X[hi] - X[-lo];
    tXX = XX[hi] + XX[-lo];
    tY = Y[hi] + Y[-lo];
    tXY = XY[hi] - XY[-lo];

    A = tY * tXX - tX * tXY;
    B = tN * tXY - tX * tY;
    D = tN * tXX - tX * tX;
    R = (A + x * B) / D;
    if (R < 0.f) R = 0.f;

    noise[i] = R - offset;
  }

  for ( ; i < n; i++, x += 1.f) {

    lo = b[i] >> 16;
    hi = b[i] & 0xffff;
    if( lo<0 || lo>=n ) break;
    if( hi>=n ) break;

    tN = N[hi] - N[lo];
    tX = X[hi] - X[lo];
    tXX = XX[hi] - XX[lo];
    tY = Y[hi] - Y[lo];
    tXY = XY[hi] - XY[lo];

    A = tY * tXX - tX * tXY;
    B = tN * tXY - tX * tY;
    D = tN * tXX - tX * tX;
    R = (A + x * B) / D;
    if (R < 0.f) R = 0.f;

    noise[i] = R - offset;
  }

  for ( ; i < n; i++, x += 1.f) {

    R = (A + x * B) / D;
    if (R < 0.f) R = 0.f;

    noise[i] = R - offset;
  }

  if (fixed <= 0) return;

  for (i = 0, x = 0.f; i < n; i++, x += 1.f) {
    hi = i + fixed / 2;
    lo = hi - fixed;
    if ( hi>=n ) break;
    if ( lo>=0 ) break;

    tN = N[hi] + N[-lo];
    tX = X[hi] - X[-lo];
    tXX = XX[hi] + XX[-lo];
    tY = Y[hi] + Y[-lo];
    tXY = XY[hi] - XY[-lo];


    A = tY * tXX - tX * tXY;
    B = tN * tXY - tX * tY;
    D = tN * tXX - tX * tX;
    R = (A + x * B) / D;

    if (R - offset < noise[i]) noise[i] = R - offset;
  }
  for ( ; i < n; i++, x += 1.f) {

    hi = i + fixed / 2;
    lo = hi - fixed;
    if ( hi>=n ) break;
    if ( lo<0 ) break;

    tN = N[hi] - N[lo];
    tX = X[hi] - X[lo];
    tXX = XX[hi] - XX[lo];
    tY = Y[hi] - Y[lo];
    tXY = XY[hi] - XY[lo];

    A = tY * tXX - tX * tXY;
    B = tN * tXY - tX * tY;
    D = tN * tXX - tX * tX;
    R = (A + x * B) / D;

    if (R - offset < noise[i]) noise[i] = R - offset;
  }
  for ( ; i < n; i++, x += 1.f) {
    R = (A + x * B) / D;
    if (R - offset < noise[i]) noise[i] = R - offset;
  }
#endif														/* SSE Optimize */
}

/*  aoTuV M7
    This revise that a tone ingredient is underestimated by calculation of noise making.
      [blocksize is 512/4096 or 256/2048]
    by Aoyumi @ 2010/04/28 - 2011/01/30(v1.1)
*/
static void ntfix(const vorbis_look_psy *p,
                    const float *spectral,
                    float *noise,
                    int block_mode){
  int i,j,k;
  int n=p->n;
  int nx=p->tonefix_end;
  float *temp, *inmod;
  float limit=fabs(p->noiseoffset[1][0]);

  if(!nx)return;

  temp=alloca(256*sizeof(*temp));
  inmod=alloca(256*sizeof(*inmod));

  memset(temp, 0, 256*sizeof(*temp));
  memset(inmod, 0, 256*sizeof(*inmod));

  if(block_mode<=1){
    //// short (impulse, padding)
    const int freq_upc=3;
    const int freq_unc=4;
    int nxplus=nx+freq_unc;

    float tolerance=9.f;
    float strength=.6f;
    if(n==256)tolerance=15.f;
    if(nxplus>n){
      nx=n;
      nxplus=n-freq_unc;
    }

    for(i=0; i<nxplus; i++){
      if(spectral[i]<-70)inmod[i]=-70+(spectral[i]+70)*.1;
      else inmod[i]=spectral[i];
    }
    for(i=freq_unc; i<nx; i++){   // nx is alredy small than n
      if((spectral[i]>spectral[i-1]) && (spectral[i]>spectral[i+1])){ // peak detection
        int ps=i-1;
        int pe=i+1;
        int upper=i-freq_upc;
        int under=i+freq_unc;
        // search a range
        for(j=ps; j>upper; j--){
          if(spectral[j+1]<spectral[j])break;
          ps=j;
        }
        for(j=pe; j<under; j++){
          if(spectral[j-1]<spectral[j])break;
          pe=j;
        }
        {
          float ss=inmod[i]-inmod[ps];
          ss=max(ss, inmod[i]-inmod[pe]);
          if(ss>tolerance){
            if(spectral[i]>noise[i]){
              ss-=tolerance;
              ss*=strength;
            }
            //else{
            //  float ts=noise[i]-spectral[i];
            //  if(ts<9)ss-=ts;
            //}
            for(j=ps; j<=pe; j++){
              temp[j]=max(ss, temp[j]);
              if(temp[j]<0)temp[j]=0;
            }
          }
        }
        i=pe;
      }
    }
    for(i=freq_unc-1; i<nx; i++){
      float test=min(p->ntfix_noiseoffset[i], p->noiseoffset[1][i]+limit); // limit
      if(temp[i]>test)temp[i]=test;
      //if(temp[j]<0)temp[j]=0;
      noise[i]-=temp[i];
    }

  }else if(block_mode==2){
    //// transition (start/stop)
    // become average every eight coefficients.
    for(i=0,k=0; i<nx; i+=8,k++){
      double na=0;
      for(j=0; j<8; j++)na+=noise[i+j];
      na/=8;
      temp[k]=na;
    }
    nx/=8;
    for(i=3; i<nx; i++){
      if((temp[i]>temp[i-1]) && (temp[i]>temp[i+1])){ // peak detection
        int a=0;
        int b=0;
        float thres=0;

        if(temp[i-1]>temp[i-2]){
          thres=temp[i-2];
          a=i-3;
        }else{
          thres=temp[i-1];
          a=i-2;
        }
        //if(temp[i+1]>temp[i+2]){
        //  b=i+2;
        //}else{
        //  b=i+2;
        //}
        b=i+3;
        thres=temp[i]-thres;
        if(thres>2.){
          int eightimes=i*8;
          float test=min(p->ntfix_noiseoffset[eightimes], p->noiseoffset[1][eightimes]+limit); // limit
          thres=min(thres-2, test);
          a*=8;
          b*=8;
          //if(thres<0)thres=0;
          for(j=a; j<=b; j++)noise[j]-=thres;
        }
      }
    }
  }/*else{
    // long block
  }*/
}

void _vp_noisemask(const vorbis_look_psy *p,
                   const float noise_compand_level,
                   const float *logmdct,
                   const float *lastmdct,
                   float *epeak,
                   float *npeak,
                   float *logmask,
                   float poste,
                   int block_mode){

  int i,j,k,n=p->n;
  int partition=(p->vi->normal_p ? p->vi->normal_partition : 16);
#ifdef __SSE__												/* SSE Optimize */
	float *work		 = (float*)_ogg_alloca(n*sizeof(*work)*3);
	float *bwork	 = (float*)_ogg_alloca(n*sizeof(float)*5);
#else														/* SSE Optimize */
  float *work=alloca(n*sizeof(*work));
#endif														/* SSE Optimize */

#ifdef __SSE__												/* SSE Optimize */
	bark_noise_hybridmp(p,logmdct,logmask,
		      140.,-1, bwork, work+n);

	for(i=0;i<n;i+=16)
	{
		__m128	XMM0, XMM1, XMM2, XMM3;
		__m128	XMM4, XMM5, XMM6, XMM7;
		XMM0	 = _mm_load_ps(logmdct+i   );
		XMM4	 = _mm_load_ps(logmask+i   );
		XMM1	 = _mm_load_ps(logmdct+i+ 4);
		XMM5	 = _mm_load_ps(logmask+i+ 4);
		XMM2	 = _mm_load_ps(logmdct+i+ 8);
		XMM6	 = _mm_load_ps(logmask+i+ 8);
		XMM3	 = _mm_load_ps(logmdct+i+12);
		XMM7	 = _mm_load_ps(logmask+i+12);
		XMM0	 = _mm_sub_ps(XMM0, XMM4);
		XMM1	 = _mm_sub_ps(XMM1, XMM5);
		XMM2	 = _mm_sub_ps(XMM2, XMM6);
		XMM3	 = _mm_sub_ps(XMM3, XMM7);
		_mm_store_ps(work+i   , XMM0);
		_mm_store_ps(work+i+ 4, XMM1);
		_mm_store_ps(work+i+ 8, XMM2);
		_mm_store_ps(work+i+12, XMM3);
	}

	bark_noise_hybridmp(p,work,logmask,0.,
		      p->vi->noisewindowfixed, bwork, work+n);
#else														/* SSE Optimize */
  bark_noise_hybridmp(n,p->bark,logmdct,logmask,
                      140.,-1);

  for(i=0;i<n;i++)work[i]=logmdct[i]-logmask[i];

  bark_noise_hybridmp(n,p->bark,work,logmask,0.,
                      p->vi->noisewindowfixed);
#endif														/* SSE Optimize */

#ifdef __SSE__												/* SSE Optimize */
	for(i=0;i<n;i+=16)
	{
		__m128	XMM0, XMM1, XMM2, XMM3;
		__m128	XMM4, XMM5, XMM6, XMM7;
		XMM0	 = _mm_load_ps(logmdct+i   );
		XMM4	 = _mm_load_ps(work+i   );
		XMM1	 = _mm_load_ps(logmdct+i+ 4);
		XMM5	 = _mm_load_ps(work+i+ 4);
		XMM2	 = _mm_load_ps(logmdct+i+ 8);
		XMM6	 = _mm_load_ps(work+i+ 8);
		XMM3	 = _mm_load_ps(logmdct+i+12);
		XMM7	 = _mm_load_ps(work+i+12);
		XMM0	 = _mm_sub_ps(XMM0, XMM4);
		XMM1	 = _mm_sub_ps(XMM1, XMM5);
		XMM2	 = _mm_sub_ps(XMM2, XMM6);
		XMM3	 = _mm_sub_ps(XMM3, XMM7);
		_mm_store_ps(work+i   , XMM0);
		_mm_store_ps(work+i+ 4, XMM1);
		_mm_store_ps(work+i+ 8, XMM2);
		_mm_store_ps(work+i+12, XMM3);
	}
#else														/* SSE Optimize */
  for(i=0;i<n;i++)work[i]=logmdct[i]-work[i];
#endif														/* SSE Optimize */

#if 0
  {
    static int seq=0;

    float work2[n];
    for(i=0;i<n;i++){
      work2[i]=logmask[i]+work[i];
    }

    if(seq&1)
      _analysis_output("median2R",seq/2,work,n,1,0,0);
    else
      _analysis_output("median2L",seq/2,work,n,1,0,0);

    if(seq&1)
      _analysis_output("envelope2R",seq/2,work2,n,1,0,0);
    else
      _analysis_output("envelope2L",seq/2,work2,n,1,0,0);
    seq++;
  }
#endif

  ntfix(p, logmdct, work, block_mode);

  /* noise compand & aoTuV M5 extension & pre sotre tone peak. */
  i=0;
  if(noise_compand_level > 0){
    int thter = p->n33p;
    for(;i<thter;i++){
      int dB=logmask[i]+.5;
      if(dB>=NOISE_COMPAND_LEVELS)dB=NOISE_COMPAND_LEVELS-1;
      if(dB<0)dB=0;
      epeak[i]= work[i]+stn_compand[dB];
      logmask[i]= work[i]+p->vi->noisecompand[dB]-
       ((p->vi->noisecompand[dB]-p->vi->noisecompand_high[dB])*noise_compand_level);
    }
  }
#ifdef __SSE__												/* SSE Optimize */
	{
		static _MM_ALIGN16 const float NCLMAX[4]	 = {
			NOISE_COMPAND_LEVELS-1, NOISE_COMPAND_LEVELS-1,
			NOISE_COMPAND_LEVELS-1, NOISE_COMPAND_LEVELS-1
		};
		int spm4 = (i+15)&(~15);
		for(;i<spm4;i++){
			int dB=logmask[i]+.5;
			if(dB>=NOISE_COMPAND_LEVELS) dB=NOISE_COMPAND_LEVELS-1;
			if(dB<0) dB=0;
			epeak[i] = work[i]+stn_compand[dB];
		    logmask[i] = work[i]+p->vi->noisecompand[dB];
		}
		{
			register float* fwork2	 = (float*)(work+n);
			register float* fwork3	 = (float*)(work+2*n);
			for(i=spm4;i<n;i+=16)
			{
#if	!defined(__SSE2__)
				__m64	MM0, MM1, MM2, MM3, MM4, MM5, MM6, MM7;
#endif
				__m128	XMM0, XMM1, XMM2, XMM3;
				XMM0	 = _mm_load_ps(logmask+i   );
				XMM1	 = _mm_load_ps(logmask+i+ 4);
				XMM2	 = _mm_load_ps(logmask+i+ 8);
				XMM3	 = _mm_load_ps(logmask+i+12);
				XMM0	 = _mm_min_ps(XMM0, PM128(NCLMAX));
				XMM1	 = _mm_min_ps(XMM1, PM128(NCLMAX));
				XMM2	 = _mm_min_ps(XMM2, PM128(NCLMAX));
				XMM3	 = _mm_min_ps(XMM3, PM128(NCLMAX));
				XMM0	 = _mm_max_ps(XMM0, PM128(PFV_0));
				XMM1	 = _mm_max_ps(XMM1, PM128(PFV_0));
				XMM2	 = _mm_max_ps(XMM2, PM128(PFV_0));
				XMM3	 = _mm_max_ps(XMM3, PM128(PFV_0));
#if	defined(__SSE2__)
				_mm_store_si128((__m128i*)(fwork2+i   ), _mm_cvtps_epi32(XMM0));
				_mm_store_si128((__m128i*)(fwork2+i+ 4), _mm_cvtps_epi32(XMM1));
				_mm_store_si128((__m128i*)(fwork2+i+ 8), _mm_cvtps_epi32(XMM2));
				_mm_store_si128((__m128i*)(fwork2+i+12), _mm_cvtps_epi32(XMM3));
			}
#else
				MM0		 = _mm_cvtps_pi32(XMM0);
				MM2		 = _mm_cvtps_pi32(XMM1);
				MM4		 = _mm_cvtps_pi32(XMM2);
				MM6 	 = _mm_cvtps_pi32(XMM3);
				XMM0	 = _mm_movehl_ps(XMM0, XMM0);
				XMM1	 = _mm_movehl_ps(XMM1, XMM1);
				XMM2	 = _mm_movehl_ps(XMM2, XMM2);
				XMM3	 = _mm_movehl_ps(XMM3, XMM3);
				MM1		 = _mm_cvtps_pi32(XMM0);
				MM3		 = _mm_cvtps_pi32(XMM1);
				MM5		 = _mm_cvtps_pi32(XMM2);
				MM7		 = _mm_cvtps_pi32(XMM3);
				PM64(fwork2+i   )	 = MM0;
				PM64(fwork2+i+ 4)	 = MM2;
				PM64(fwork2+i+ 8)	 = MM4;
				PM64(fwork2+i+ 2)	 = MM1;
				PM64(fwork2+i+12)	 = MM6;
				PM64(fwork2+i+ 6)	 = MM3;
				PM64(fwork2+i+10)	 = MM5;
				PM64(fwork2+i+14)	 = MM7;
			}
			_mm_empty();
#endif
			for(i=spm4;i<n;i+=4)
			{
				fwork3[i  ]	 = stn_compand[*((int*)(fwork2+i  ))];
				fwork3[i+1]	 = stn_compand[*((int*)(fwork2+i+1))];
				fwork3[i+2]	 = stn_compand[*((int*)(fwork2+i+2))];
				fwork3[i+3]	 = stn_compand[*((int*)(fwork2+i+3))];
			}
			for(i=spm4;i<n;i+=4)
			{
				fwork2[i  ]	 = p->vi->noisecompand[*((int*)(fwork2+i  ))];
				fwork2[i+1]	 = p->vi->noisecompand[*((int*)(fwork2+i+1))];
				fwork2[i+2]	 = p->vi->noisecompand[*((int*)(fwork2+i+2))];
				fwork2[i+3]	 = p->vi->noisecompand[*((int*)(fwork2+i+3))];
			}
			//epeak[i] = work[i]+stn_compand[dB];
		    //logmask[i] = work[i]+p->vi->noisecompand[dB];
			for(i=spm4;i<n;i+=16)
			{
				__m128	XMM0	 = _mm_load_ps(fwork2+i   );
				__m128	XMM4	 = _mm_load_ps(work+i   );
				__m128	XMM1	 = _mm_load_ps(fwork2+i+ 4);
				__m128	XMM5	 = _mm_load_ps(work+i+ 4);
				__m128	XMM2	 = _mm_load_ps(fwork2+i+ 8);
				__m128	XMM6	 = _mm_load_ps(work+i+ 8);
				__m128	XMM3	 = _mm_load_ps(fwork2+i+12);
				__m128	XMM7	 = _mm_load_ps(work+i+12);
				XMM0	 = _mm_add_ps(XMM0, XMM4);
				XMM1	 = _mm_add_ps(XMM1, XMM5);
				XMM2	 = _mm_add_ps(XMM2, XMM6);
				XMM3	 = _mm_add_ps(XMM3, XMM7);
				_mm_store_ps(logmask+i   , XMM0);
				_mm_store_ps(logmask+i+ 4, XMM1);
				_mm_store_ps(logmask+i+ 8, XMM2);
				_mm_store_ps(logmask+i+12, XMM3);

				XMM0	 = _mm_load_ps(fwork3+i   );
				XMM1	 = _mm_load_ps(fwork3+i+ 4);
				XMM2	 = _mm_load_ps(fwork3+i+ 8);
				XMM3	 = _mm_load_ps(fwork3+i+12);
				XMM0	 = _mm_add_ps(XMM0, XMM4);
				XMM1	 = _mm_add_ps(XMM1, XMM5);
				XMM2	 = _mm_add_ps(XMM2, XMM6);
				XMM3	 = _mm_add_ps(XMM3, XMM7);
				_mm_store_ps(epeak+i   , XMM0);
				_mm_store_ps(epeak+i+ 4, XMM1);
				_mm_store_ps(epeak+i+ 8, XMM2);
				_mm_store_ps(epeak+i+12, XMM3);
			}
		}
	}
#else														/* SSE Optimize */
  for(;i<n;i++){
    int dB=logmask[i]+.5;
    if(dB>=NOISE_COMPAND_LEVELS)dB=NOISE_COMPAND_LEVELS-1;
    if(dB<0)dB=0;
    epeak[i]= work[i]+stn_compand[dB];
    logmask[i]= work[i]+p->vi->noisecompand[dB];
  }
#endif														/* SSE Optimize */

  /* initialization of npeak(nepeak) */
  for(i=0,k=0; i<n; i+=partition, k++)npeak[k]=0.f;

  /* reduction of post-echo. (postprocessing of aoTuV M2) */
  if(poste>0){
    for(i=0,k=0; i<p->min_nn_lp; i+=partition,k++){
      float temp=min(min(poste,30.f), p->noiseoffset[1][i]+30.f); // limit
      if(temp<=0)continue;
      npeak[k]=-1.f; // this time, don't use noise normalization
      for(j=0; j<partition; j++) logmask[i+j]-=temp;
    }
  }

  /* AoTuV */
  /** @ M8 MAIN **
    store non peak logmask(floor) for noise normalization.
    npeak (each partition) = min [0 ~ 1.0f] max
    by Aoyumi @ 2010/09/28
  */
  for(k=0, i=0; i<p->min_nn_lp; i+=partition,k++){
    const float nt=4;
    float o=p->noiseoffset[1][i+partition-1]+6;  // threshold of offset
    float me=0;  // max energy (per partition)
    float avge=0; // average energy (per partition)

    if(o<=0)continue;
    if(npeak[k]<-0.5)continue;

    for(j=0; j<partition; j++){
      float temp=logmdct[i+j]-logmask[i+j];
      if(me<temp)me=temp;
      avge+=logmdct[i+j];
    }
    if(avge < (-95*partition))continue; // limit (MDCT AVG. /dB)

    if(me<nt){
      npeak[k]=(min(o, nt-me))/nt;
    }
  }

  /* AoTuV */
  /** @ M9 MAIN **
    store peak impuse for coupling stereo. (to epeak)
    by Aoyumi @ 2010/05/05
  */
  {
    i=0;
    if(block_mode>1){ // long and trans. block
      for(; i<p->tonecomp_endp; i++){
        float temp=logmdct[i]-epeak[i];
        epeak[i]=0.f;
        if(temp>=12.f){
          float mi=logmdct[i]-lastmdct[i];
          if(mi>=1)epeak[i]=mi;
        }
      }
    }
    memset(epeak+i,0,sizeof(epeak[0])*(n-i));
  }
}

void _vp_tonemask(const vorbis_look_psy *p,
                  const float *logfft,
                  float *logmask,
                  const float global_specmax,
                  const float local_specmax){

  int i,n=p->n;

#ifdef __SSE__												/* SSE Optimize */
	int seedsize = (p->total_octave_lines+31)&(~31);
	float *seed = (float*)_ogg_alloca(sizeof(*seed)*seedsize);
	float att=local_specmax+p->vi->ath_adjatt;
	{
		__m128	XMM0	 = PM128(PNEGINF);
		for(i=0;i<seedsize;i+=32)
		{
			_mm_store_ps(seed+i   , XMM0);
			_mm_store_ps(seed+i+ 4, XMM0);
			_mm_store_ps(seed+i+ 8, XMM0);
			_mm_store_ps(seed+i+12, XMM0);
			_mm_store_ps(seed+i+16, XMM0);
			_mm_store_ps(seed+i+20, XMM0);
			_mm_store_ps(seed+i+24, XMM0);
			_mm_store_ps(seed+i+28, XMM0);
		}
	}
	/* set the ATH (floating below localmax, not global max by a
	   specified att) */
	if(att<p->vi->ath_maxatt)att=p->vi->ath_maxatt;

	{
		__m128	pm = _mm_set_ps1(att);
		for(i=0;i<n;i+=16)
		{
			__m128	XMM0, XMM1, XMM2, XMM3;
			XMM0	 = _mm_load_ps(p->ath+i   );
			XMM1	 = _mm_load_ps(p->ath+i+ 4);
			XMM2	 = _mm_load_ps(p->ath+i+ 8);
			XMM3	 = _mm_load_ps(p->ath+i+12);
			XMM0	 = _mm_add_ps(XMM0, pm);
			XMM1	 = _mm_add_ps(XMM1, pm);
			XMM2	 = _mm_add_ps(XMM2, pm);
			XMM3	 = _mm_add_ps(XMM3, pm);
			_mm_store_ps(logmask+i   , XMM0);
			_mm_store_ps(logmask+i+ 4, XMM1);
			_mm_store_ps(logmask+i+ 8, XMM2);
			_mm_store_ps(logmask+i+12, XMM3);
		}
	}
#else														/* SSE Optimize */
  float *seed=alloca(sizeof(*seed)*p->total_octave_lines);
  float att=local_specmax+p->vi->ath_adjatt;
  for(i=0;i<p->total_octave_lines;i++)seed[i]=NEGINF;

  /* set the ATH (floating below localmax, not global max by a
     specified att) */
  if(att<p->vi->ath_maxatt)att=p->vi->ath_maxatt;

  for(i=0;i<n;i++)
    logmask[i]=p->ath[i]+att;
#endif														/* SSE Optimize */

  /* tone masking */
  seed_loop(p,(const float ***)p->tonecurves,logfft,logmask,seed,global_specmax);
  max_seeds(p,seed,logmask);

}

/*
   @ M3 PRE
     set parameters for aoTuV M3
*/
static void set_m3p(local_mod3_psy *mp, const int lW_no, const int impadnum,
             const int n, const int hs_rate, const float toneatt,
             const float *logmdct, const float *lastmdct, float *tempmdct,
             const int block_mode, const int lW_block_mode,
             const int bit_managed, const int offset_select){

  int i,j, count;
  float freqbuf, cell;

  /* lower sampling rate */
  if(!hs_rate){
    mp->sw = 0;
    mp->mdctbuf_flag=0;
    return;
  }

  /* set flag for lastmdct and tempmdct */
  if(!bit_managed || offset_select==2){
    mp->mdctbuf_flag=1;
  }else{
    mp->mdctbuf_flag=0;
    if(offset_select==0){ // high noise scene
      mp->sw = 0;
      return;
    }
  }

  /* non impulse */
  if(block_mode){
    mp->sw = 0;
    return;
  }

  /** M3 PRE **/
  switch(n){

    case 128:
      if(toneatt < 3) count = 2; // q6~
      else count = 3;

      if(!lW_block_mode){ /* last window "short" - type "impulse" */
        if(lW_no < 8){
          /* impulse - @impulse case1 */
          mp->noise_rate = 0.7-(float)(lW_no-1)/17;
          mp->noise_center = (float)(lW_no*count);
          mp->tone_rate = 8-lW_no;
        }else{
          /* impulse - @impulse case2 */
          mp->noise_rate = 0.3;
          mp->noise_center = 25;
          mp->tone_rate = 0;
          if((lW_no*count) < 24) mp->noise_center = lW_no*count;
        }
          if(mp->mdctbuf_flag == 1){
            for(i=0; i<n; i++) tempmdct[i] -= 5;
          }
      }else{ /* non_impulse - @Short(impulse) case */
          mp->noise_rate = 0.7;
          mp->noise_center = 0;
          mp->tone_rate = 8.;
          if(mp->mdctbuf_flag == 1){
            for(i=0; i<n; i++) tempmdct[i] = lastmdct[i] - 5;
          }
      }
      mp->noise_rate_low = 0;
      mp->sw = 1;
      if(impadnum) mp->noise_rate*=(impadnum*0.125);
      for(i=0;i<n;i++){
          cell=75/(float)freq_bfn128[i];
          for(j=1; j<freq_bfn128[i]; j++){
            freqbuf = logmdct[i]-(cell*j);
            if((tempmdct[i+j] < freqbuf) && (mp->mdctbuf_flag == 1))
             tempmdct[i+j] += (5./(float)freq_bfn128[i+j]);
          }
      }
      break;

    case 256:
      // for q-1/-2 44.1kHz/48kHz
      if(!lW_block_mode){ /* last window "short" - type "impulse" */
          count = 6;
          if(lW_no < 4){
            /* impulse - @impulse case1 */
            mp->noise_rate = 0.4-(float)(lW_no-1)/11;
            mp->noise_center = (float)(lW_no*count+12);
            mp->tone_rate = 8-lW_no*2;
          }else{
            /* impulse - @impulse case2 */
            mp->noise_rate = 0.2;
            mp->noise_center = 30;
            mp->tone_rate = 0;
          }
          if(mp->mdctbuf_flag == 1){
            for(i=0; i<n; i++) tempmdct[i] -= 10;
          }
      }else{ /* non_impulse - @Short(impulse) case */
          mp->noise_rate = 0.6;
          mp->noise_center = 12;
          mp->tone_rate = 8.;
          if(mp->mdctbuf_flag == 1){
            for(i=0; i<n; i++) tempmdct[i] = lastmdct[i] - 10;
          }
      }
      mp->noise_rate_low = 0;
      mp->sw = 1;
      if(impadnum) mp->noise_rate*=(impadnum*0.0625);
      for(i=0;i<n;i++){
          cell=75/(float)freq_bfn256[i];
          for(j=1; j<freq_bfn256[i]; j++){
            freqbuf = logmdct[i]-(cell*j);
            if((tempmdct[i+j] < freqbuf) && (mp->mdctbuf_flag == 1))
             tempmdct[i+j] += (10./(float)freq_bfn256[i+j]);
          }
      }
      break;

    default:
      mp->sw = 0;
      break;
  }

  /* higher noise curve (lower rate) && managed mode */
  if(bit_managed && (offset_select==0) && mp->sw) mp->noise_rate*=0.2;

}

void _vp_offset_and_mix(const vorbis_look_psy *p,
                        const float *noise,
                        const float *tone,
                        const int offset_select,
                        const int bit_managed,
                        float *logmask,
                        float *mdct,
                        float *logmdct,
                        float *lastmdct, float *tempmdct,
                        float low_compand,
                        float *npeak,
                        const int end_block,
                        const int block_mode,
                        const int nW_modenumber,
                        const int lW_block_mode,
                        const int lW_no, const int impadnum){

  int i,j,k,n=p->n;
  int hsrate=((p->rate<26000) ? 0 : 1); // high sampling rate is 1
  int partition=(p->vi->normal_p ? p->vi->normal_partition : 16);
  float m1_de, m1_coeffi; /* aoTuV for M1 */
  float toneatt=p->vi->tone_masteratt[offset_select];

  local_mod3_psy mp3;
  local_mod4_psy mp4;

  /* Init for aoTuV M3 */
  memset(&mp3,0,sizeof(mp3));

  /* Init for aoTuV M4 */
  mp4.start=p->vi->normal_start;
  mp4.end = p->tonecomp_endp;
  mp4.thres = p->tonecomp_thres;
  mp4.lp_pos=9999;
  mp4.end_block=end_block;

  /* Collapse of low(mid) frequency is prevented. (for 32/44/48kHz q-2) */
  if(low_compand<0 || toneatt<25.)low_compand=0;
  else low_compand*=(toneatt-25.);

  /** @ M3 PRE **/
  set_m3p(&mp3, lW_no, impadnum, n, hsrate, toneatt, logmdct, lastmdct, tempmdct,
          block_mode, lW_block_mode,
          bit_managed, offset_select);

  /** @ M4 PRE **/
  mp4.end_block+=p->vi->normal_partition;
  if(mp4.end_block>n)mp4.end_block=n;
  if(!hsrate){
    mp4.end=mp4.end_block; /* for M4 */
  }else{
    if(p->vi->normal_thresh>1.){
      mp4.start = 9999;
    }else{
      if(mp4.end>mp4.end_block)mp4.lp_pos=mp4.end;
      else mp4.lp_pos=mp4.end_block;
    }
  }

  for(i=0;i<n;i++){
    float val= noise[i]+p->noiseoffset[offset_select][i];
    float tval= tone[i]+toneatt;
    if(i<=mp4.start)tval-=low_compand;
    if(val>p->vi->noisemaxsupp)val=p->vi->noisemaxsupp;

    /* AoTuV */
    /** @ M3 MAIN **
    Dynamic impulse block noise control. (#7)
    48/44.1/32kHz only.
    by Aoyumi @ 2008/12/01 - 2011/02/27(fixed)
    */
    if(mp3.sw){
      if(val>tval){
        if( (val>lastmdct[i]) && (logmdct[i]>(tempmdct[i]+mp3.noise_center)) ){
          int toneac=0;
          float valmask=0;
          float rate_mod;
          float mainth;

          if(mp3.mdctbuf_flag == 1)tempmdct[i] = logmdct[i]; // overwrite
          if(logmdct[i]>lastmdct[i]){
            rate_mod = mp3.noise_rate;
          }else{
            rate_mod = mp3.noise_rate_low;
          }
          // edit tone masking
          if( !impadnum && (i < p->tonecomp_endp) && ((val-lastmdct[i])>20.f) ){
            float dBsub=(logmdct[i]-lastmdct[i]);
            if(dBsub>25.f){
              toneac=1;
              if(tval>-100.f && ((logmdct[i]-tval)<48.f)){ // limit
                float tr_cur=mp3.tone_rate;
                if(dBsub<35.f) tr_cur*=((35.f-dBsub)*.1f);
                //if(dBsub<35.f) tr_cur*=((dBsub-25.f)*.1f);
                tval-=tr_cur;
                if(tval<-100.f)tval=-100.f; // lower limit = -100
                if((logmdct[i]-tval)>48.f)tval=logmdct[i]-48.f; // limit
              }
            }
          }
          // main work
          if(i > p->m3n[0]){
            mainth=30.f;
          }else if(i > p->m3n[1]){
            mainth=20.f;
          }else if(i > p->m3n[2]){
            mainth=10.f; rate_mod*=.5f;
          }else{
            mainth=10.f; rate_mod*=.3f;
          }
          if((val-tval)>mainth) valmask=((val-tval-mainth)*.1f+mainth)*rate_mod;
          else valmask=(val-tval)*rate_mod;

          if((val-valmask)>lastmdct[i])val-=valmask;
          else val=lastmdct[i];

          if(toneac){
            float temp=val-max(lastmdct[i], -140); // limit
            if(temp>20.f) val-=(temp-20.f)*.2f;
          }

          // exception of npeak(nepeak) for M8
          if(toneac==1)npeak[i/partition]=-1.f;
          else if(npeak[i/partition]>0)npeak[i/partition]=0;
        }
      }
    }

    /* AoTuV */
    /** @ M4 MAIN **
    The purpose of this portion is working noise normalization more correctly.
    (There is this in order to prevent extreme boost of floor)
      mp4.start = start point
      mp4.end   = end point
      mp4.thres = threshold
    by Aoyumi @ 2006/03/20 - 2010/06/16(fixed)
    */
    //logmask[i]=max(val,tval);
    if(val>tval){
      logmask[i]=val;
    }else if((i>mp4.start) && (i<mp4.end)){
      if(logmdct[i]<tval){
        if(logmdct[i]<val){
          tval-=(tval-val)*mp4.thres;
        }else{
          tval=logmdct[i];
        }
      }
      logmask[i]=tval;
    }else logmask[i]=tval;

    /* AoTuV */
    /** @ M1 **
    The following codes improve a noise problem.
    A fundamental idea uses the value of masking and carries out
    the relative compensation of the MDCT.
    However, this code is not perfect and all noise problems cannot be solved.
    by Aoyumi @ 2004/04/18
    */

    if(offset_select == 1) {
      m1_coeffi = -17.2;       /* coeffi is a -17.2dB threshold */
      val = val - logmdct[i];  /* val == mdct line value relative to floor in dB */

      if(val > m1_coeffi){
        /* mdct value is > -17.2 dB below floor */

        m1_de = 1.0-((val-m1_coeffi)*0.005*p->m_val);
        /* pro-rated attenuation:
           -0.00 dB boost if mdct value is -17.2dB (relative to floor)
           -0.77 dB boost if mdct value is 0dB (relative to floor)
           -1.64 dB boost if mdct value is +17.2dB (relative to floor)
           etc... */

        if(m1_de < 0) m1_de = 0.0001;
      }else
        /* mdct value is <= -17.2 dB below floor */

        m1_de = 1.0-((val-m1_coeffi)*0.0003*p->m_val);
      /* pro-rated attenuation:
         +0.00 dB atten if mdct value is -17.2dB (relative to floor)
         +0.45 dB atten if mdct value is -34.4dB (relative to floor)
         etc... */

      mdct[i] *= m1_de;
    }
  }

  /** @ M3 SET lastmdct **/
  if(mp3.mdctbuf_flag==1){
    const int mag=8;
    switch(block_mode){
      case 0: case 1:  // short block (n==128 or 256 only)
        if(nW_modenumber){ // next long (trans.) block
          for(i=0,k=0; i<n; i++,k+=mag){
            for(j=0; j<mag; j++){
              lastmdct[k+j]=logmdct[i];
            }
          }
        }else{
          memcpy(lastmdct, logmdct, n*sizeof(*lastmdct)); // next short block
        }
        break;

      case 2:  // trans. block
        if(!nW_modenumber){ // next short block
          int nsh = n >> 3; // 1/8
          for(i=0; i<nsh; i++){
            int ni=i*mag;
            lastmdct[i] = logmdct[ni];
            for(j=1; j<mag; j++){
              if(lastmdct[i] > logmdct[ni+j]){
                lastmdct[i] = logmdct[ni+j];
              }
            }
          }
        }else{
          memcpy(lastmdct, logmdct, n*sizeof(*lastmdct)); // next long block
        }
        break;

      case 3:  // long block (n==1024 or 2048)
        memcpy(lastmdct, logmdct, n*sizeof(*lastmdct));
        break;

      default: break;
    }
  }
}

float _vp_ampmax_decay(float amp, const vorbis_dsp_state *vd){
  vorbis_info *vi=vd->vi;
  codec_setup_info *ci=vi->codec_setup;
  vorbis_info_psy_global *gi=&ci->psy_g_param;

  int n=ci->blocksizes[vd->W]/2;
  float secs=(float)n/vi->rate;

  amp+=secs*gi->ampmax_att_per_sec;
  if(amp<-9999)amp=-9999;
  return(amp);
}

static float FLOOR1_fromdB_LOOKUP[256]={
  1.0649863e-07F, 1.1341951e-07F, 1.2079015e-07F, 1.2863978e-07F,
  1.3699951e-07F, 1.4590251e-07F, 1.5538408e-07F, 1.6548181e-07F,
  1.7623575e-07F, 1.8768855e-07F, 1.9988561e-07F, 2.128753e-07F,
  2.2670913e-07F, 2.4144197e-07F, 2.5713223e-07F, 2.7384213e-07F,
  2.9163793e-07F, 3.1059021e-07F, 3.3077411e-07F, 3.5226968e-07F,
  3.7516214e-07F, 3.9954229e-07F, 4.2550680e-07F, 4.5315863e-07F,
  4.8260743e-07F, 5.1396998e-07F, 5.4737065e-07F, 5.8294187e-07F,
  6.2082472e-07F, 6.6116941e-07F, 7.0413592e-07F, 7.4989464e-07F,
  7.9862701e-07F, 8.5052630e-07F, 9.0579828e-07F, 9.6466216e-07F,
  1.0273513e-06F, 1.0941144e-06F, 1.1652161e-06F, 1.2409384e-06F,
  1.3215816e-06F, 1.4074654e-06F, 1.4989305e-06F, 1.5963394e-06F,
  1.7000785e-06F, 1.8105592e-06F, 1.9282195e-06F, 2.0535261e-06F,
  2.1869758e-06F, 2.3290978e-06F, 2.4804557e-06F, 2.6416497e-06F,
  2.8133190e-06F, 2.9961443e-06F, 3.1908506e-06F, 3.3982101e-06F,
  3.6190449e-06F, 3.8542308e-06F, 4.1047004e-06F, 4.3714470e-06F,
  4.6555282e-06F, 4.9580707e-06F, 5.2802740e-06F, 5.6234160e-06F,
  5.9888572e-06F, 6.3780469e-06F, 6.7925283e-06F, 7.2339451e-06F,
  7.7040476e-06F, 8.2047000e-06F, 8.7378876e-06F, 9.3057248e-06F,
  9.9104632e-06F, 1.0554501e-05F, 1.1240392e-05F, 1.1970856e-05F,
  1.2748789e-05F, 1.3577278e-05F, 1.4459606e-05F, 1.5399272e-05F,
  1.6400004e-05F, 1.7465768e-05F, 1.8600792e-05F, 1.9809576e-05F,
  2.1096914e-05F, 2.2467911e-05F, 2.3928002e-05F, 2.5482978e-05F,
  2.7139006e-05F, 2.8902651e-05F, 3.0780908e-05F, 3.2781225e-05F,
  3.4911534e-05F, 3.7180282e-05F, 3.9596466e-05F, 4.2169667e-05F,
  4.4910090e-05F, 4.7828601e-05F, 5.0936773e-05F, 5.4246931e-05F,
  5.7772202e-05F, 6.1526565e-05F, 6.5524908e-05F, 6.9783085e-05F,
  7.4317983e-05F, 7.9147585e-05F, 8.4291040e-05F, 8.9768747e-05F,
  9.5602426e-05F, 0.00010181521F, 0.00010843174F, 0.00011547824F,
  0.00012298267F, 0.00013097477F, 0.00013948625F, 0.00014855085F,
  0.00015820453F, 0.00016848555F, 0.00017943469F, 0.00019109536F,
  0.00020351382F, 0.00021673929F, 0.00023082423F, 0.00024582449F,
  0.00026179955F, 0.00027881276F, 0.00029693158F, 0.00031622787F,
  0.00033677814F, 0.00035866388F, 0.00038197188F, 0.00040679456F,
  0.00043323036F, 0.00046138411F, 0.00049136745F, 0.00052329927F,
  0.00055730621F, 0.00059352311F, 0.00063209358F, 0.00067317058F,
  0.00071691700F, 0.00076350630F, 0.00081312324F, 0.00086596457F,
  0.00092223983F, 0.00098217216F, 0.0010459992F, 0.0011139742F,
  0.0011863665F, 0.0012634633F, 0.0013455702F, 0.0014330129F,
  0.0015261382F, 0.0016253153F, 0.0017309374F, 0.0018434235F,
  0.0019632195F, 0.0020908006F, 0.0022266726F, 0.0023713743F,
  0.0025254795F, 0.0026895994F, 0.0028643847F, 0.0030505286F,
  0.0032487691F, 0.0034598925F, 0.0036847358F, 0.0039241906F,
  0.0041792066F, 0.0044507950F, 0.0047400328F, 0.0050480668F,
  0.0053761186F, 0.0057254891F, 0.0060975636F, 0.0064938176F,
  0.0069158225F, 0.0073652516F, 0.0078438871F, 0.0083536271F,
  0.0088964928F, 0.009474637F, 0.010090352F, 0.010746080F,
  0.011444421F, 0.012188144F, 0.012980198F, 0.013823725F,
  0.014722068F, 0.015678791F, 0.016697687F, 0.017782797F,
  0.018938423F, 0.020169149F, 0.021479854F, 0.022875735F,
  0.024362330F, 0.025945531F, 0.027631618F, 0.029427276F,
  0.031339626F, 0.033376252F, 0.035545228F, 0.037855157F,
  0.040315199F, 0.042935108F, 0.045725273F, 0.048696758F,
  0.051861348F, 0.055231591F, 0.058820850F, 0.062643361F,
  0.066714279F, 0.071049749F, 0.075666962F, 0.080584227F,
  0.085821044F, 0.091398179F, 0.097337747F, 0.10366330F,
  0.11039993F, 0.11757434F, 0.12521498F, 0.13335215F,
  0.14201813F, 0.15124727F, 0.16107617F, 0.17154380F,
  0.18269168F, 0.19456402F, 0.20720788F, 0.22067342F,
  0.23501402F, 0.25028656F, 0.26655159F, 0.28387361F,
  0.30232132F, 0.32196786F, 0.34289114F, 0.36517414F,
  0.38890521F, 0.41417847F, 0.44109412F, 0.46975890F,
  0.50028648F, 0.53279791F, 0.56742212F, 0.60429640F,
  0.64356699F, 0.68538959F, 0.72993007F, 0.77736504F,
  0.82788260F, 0.88168307F, 0.9389798F, 1.F,
};

static void flag_lossless(int limit, float prepoint, float postpoint, float prepoint_r, float postpoint_r,
                          float *res, float *mdct, float *enpeak, float *floor, int *flag, int i, int jn){
  int j, ps=0;
  int pointlimit=limit-i;
  float point1, point2, bakp1, r;
  float ps1, ps2;

  if(pointlimit>0){
    point1=prepoint;
    point2=prepoint_r;
    if((pointlimit-jn)<=0){ // pointlimit is 1~32.
      ps1=(postpoint-prepoint)/jn;
      ps2=(postpoint_r-prepoint_r)/jn;
      ps=1;
    }
  }else{
    point1=postpoint;
    point2=postpoint_r;
  }
  for(j=0;j<jn;j++){
    if(ps==1){
      point1+=ps1;
      point2+=ps2;
    }
    bakp1=point1;

    res[j] = mdct[j]/floor[j];
    r = fabs(res[j]);
    point1-=enpeak[j]; // reflect enpeak
    if(point1<prepoint)point1=prepoint;
    if(r<point1){
      if(r<point2){
        flag[j]=0;
      }else
        flag[j]=-1;
    }else{
      flag[j]=1;
    }
    point1=bakp1;
  }
}

static void lossless_coupling(int *Mag, int *Ang){
  int A = *Mag;
  int B = *Ang;

  if(abs(A)>abs(B)){
    *Ang=(A>0?A-B:B-A);
  }else{
    *Ang=(B>0?A-B:B-A);
    *Mag=B;
  }
   /* collapse two equivalent tuples to one */
  if(*Ang>=abs(*Mag)*2){
    *Ang= -*Ang;
    *Mag= -*Mag;
  }
}

static void lossless_couplingf(float *Mag, float *Ang){
  float A = *Mag;
  float B = *Ang;

  if(fabs(A)>fabs(B)){
    *Ang=(A>0?A-B:B-A);
  }else{
    *Ang=(B>0?A-B:B-A);
    *Mag=B;
  }
   /* collapse two equivalent tuples to one */
  if(*Ang>=fabs(*Mag)*2){
    *Ang= -*Ang;
    *Mag= -*Mag;
  }
}

static float min_indemnity_dipole_hypot(const float a, const float b, const float threv){
  const float thnor=0.94;
  float a2 = fabs(a*thnor);
  float b2 = fabs(b*thnor);

  if(a>0.){
    if(b>0.)return (a2+b2);
    if(a>-b)return (a2-b2*threv);
    return -(b2-a2*threv);
  }
  if(b<0.)return -(a2+b2);
  if(-a>b)return -(a2-b2*threv);
  return (b2-a2*threv);
}

// OLD HYPOT
/*   doing the real circular magnitude calculation is audibly superior
   to (A+B)/sqrt(2) */
/*static float dipole_hypot(const float a, const float b){
  if(a>0.){
    if(b>0.)return sqrt(a*a+b*b);
    if(a>-b)return sqrt(a*a-b*b);
    return -sqrt(b*b-a*a);
  }
  if(b<0.)return -sqrt(a*a+b*b);
  if(-a>b)return -sqrt(a*a-b*b);
  return sqrt(b*b-a*a);
}
static float round_hypot(const float a, const float b){
  if(a>0.){
    if(b>0.)return sqrt(a*a+b*b);
    if(a>-b)return sqrt(a*a+b*b);
    return -sqrt(b*b+a*a);
  }
  if(b<0.)return -sqrt(a*a+b*b);
  if(-a>b)return -sqrt(a*a+b*b);
  return sqrt(b*b+a*a);
}*/

/* this is for per-channel noise normalization */
/*
static int apsort(const void *a, const void *b){
  float f1=**(float**)a;
  float f2=**(float**)b;
  return (f1<f2)-(f1>f2);
}*/


/* Selection Sort+ */
static void ssort(const int range, int bthresh, float **sort){
  int i,j;
  int large;
  float *temp;

  if(range<bthresh)bthresh=range;
  for(i=0; i<bthresh; i++){
    large=i;
    for(j=i+1; j<range; j++){
      // ascending order
      if(*sort[large]<*sort[j])large=j;
    }
    // swap
    temp=sort[i];
    sort[i]=sort[large];
    sort[large]=temp;
  }
}

/* Overload/Side effect: On input, the *q vector holds either the
   quantized energy (for elements with the flag set) or the absolute
   values of the *r vector (for elements with flag unset).  On output,
   *q holds the quantized energy for all elements */
static float noise_normalize(const vorbis_look_psy *p, const int limit, float *r, float *q, const float *f, float *res,
                             const int *flags, float acc, const float nepeak, const int i, const int n, int *out){
  vorbis_info_psy *vi=p->vi;
  float **sort = alloca(n*sizeof(*sort));
  int j,k,count=0;
  int start = (vi->normal_p ? vi->normal_start-i : n);
  //if(start>n)start=n;
  if((start>n) || (nepeak<-0.5))start=n;

  /* force classic behavior where only energy in the current band is considered */
  acc=0.f;

  /* still responsible for populating *out where noise norm not in
     effect.  There's no need to [re]populate *q in these areas */
  j=0;
  if(!flags){                  /* per channel working (lossless and mono) */
    for(;j<start;j++){
      out[j] = rint(res[j]);
    }
  }else{
    for(;j<start;j++){
      if(flags[j]!=1){         /* lossless coupling already quantized.
                                  Don't touch; requantizing based on
                                  energy would be incorrect. */
        //out[j] = rint(res[j]);
        // set residue for M6
        float ve = sqrt(q[j]/f[j]);
        if(r[j]<0){
          out[j] = -rint(ve);
          res[j] = -ve;
        }else{
          out[j] = rint(ve);
          res[j] = ve;
        }
      }
    }
  }

  /* sort magnitudes for noise norm portion of partition */
  if(flags){
    for(;j<n;j++){
      float ve;

      /* flags[j]!=1 is lossy coupled element */
      if(flags[j]!=1){   /* can't noise norm elements that have
                          already been loslessly coupled; we can
                          only account for their energy error */
        ve = q[j]/f[j];
      }else{
        /* lossless coupled element (use per channel element) */
        continue;
        /* again, no energy adjustment for error in nonzero quant-- for now */
      }
      /* Despite all the new, more capable coupling code, for now we
         implement noise norm as it has been up to this point. Only
         consider promotions to unit magnitude from 0.  In addition
         the only energy error counted is quantizations to zero. */
      /* also-- the original point code only applied noise norm at > pointlimit */
      if(ve<.25f && j>=limit-i){
        acc += ve;
        sort[count++]=q+j; /* q is fabs(r) for unflagged element */
        /* set residue for M6 */
        if(r[j]<0){
          res[j] = -sqrt(ve);
        }else{
          res[j] = sqrt(ve);
        }
      }else{
        /* For now: no acc adjustment for nonzero quantization.  populate *out and q as this value is final. */
        /* set residue for M6 */
        ve=sqrt(ve);
        if(r[j]<0){
          out[j] = -rint(ve);
          res[j] = -ve;
        }else{
          out[j] = rint(ve);
          res[j] = ve;
        }
        q[j] = out[j]*out[j]*f[j];
      }
    }
  }else{
    /* per channel working (lossless and mono) */
    for(;j<n;j++){
      float ve=res[j]*res[j];
      if(ve<.25f){
        acc += ve;
        sort[count++]=q+j; /* q is fabs(r) for unflagged element */
      }else{
        /* For now: no acc adjustment for nonzero quantization.  populate *out and q as this value is final. */
        /* set residue for M6 */
        out[j]=rint(res[j]);
        q[j] = out[j]*out[j]*f[j];
      }
    }
  }

  acc+=acc*nepeak*nepeak;

  if(count){
    /* noise norm to do */
    int iacc=((int)acc)+1;
    if(iacc>n)iacc=n;
    // Selection Sort (when there are few elements, this is faster than qsort)
    ssort(count, iacc, sort);
    // Quick Sort
    //qsort(sort,count,sizeof(*sort),apsort);

    for(k=0;k<count;k++){
      int e=sort[k]-q;
      if(acc>=vi->normal_thresh){
        out[e]=unitnorm(r[e]);
        acc-=1.f;
        q[e]=f[e];
      }else{
        out[e]=0;
        q[e]=0.f;
      }
    }
  }

  return acc;
}

/* Noise normalization, quantization and coupling are not wholly
   seperable processes in depth>1 coupling. */
void _vp_couple_quantize_normalize(int blobno,
                                   vorbis_info_psy_global *g,
                                   vorbis_look_psy *p,
                                   vorbis_info_mapping0 *vi,
                                   float **mdct,
                                   float **enpeak,
                                   float **nepeak,
                                   int   **iwork,
                                   int    *nonzero,
                                   int     sliding_lowpass,
                                   int     ch,
                                   int     lowpassr){

  int i,pi;
  int n = p->n;
  int partition=(p->vi->normal_p ? p->vi->normal_partition : 16);
  int limit = g->coupling_pointlimit[p->vi->blockflag][blobno];
  float prepoint=stereo_threshholds[g->coupling_prepointamp[blobno]];
  float postpoint=stereo_threshholds[g->coupling_postpointamp[blobno]];
  float prepoint_x=stereo_threshholds_X[g->coupling_prepointamp[blobno]];
  float postpoint_x=stereo_threshholds_X[g->coupling_postpointamp[blobno]];
  float prae;

  /* mdct is our raw mdct output, floor not removed. */
  /* inout passes in the ifloor, passes back quantized result */

  /* unquantized energy (negative indicates amplitude has negative sign) */
  float **raw = alloca(ch*sizeof(*raw));

  /* quantized energy (if flag set), otherwise mdct */
  float **quant = alloca(ch*sizeof(*quant));

  /* floor energy */
  float **floor = alloca(ch*sizeof(*floor));

  /* residue for M6 */
  float **res   = alloca(ch*sizeof(*res));

  /* flags indicating raw/quantized status of elements in raw vector */
  int   **flag  = alloca(ch*sizeof(*flag));

  /* non-zero flag working vector */
  int    *nz    = alloca(ch*sizeof(*nz));

  /* energy surplus/defecit tracking */
  float  *acc   = alloca((ch+vi->coupling_steps)*sizeof(*acc));

  /* var for M6 */
  float  *side_resdef= alloca(vi->coupling_steps*sizeof(*side_resdef));

  raw[0]   = alloca(ch*partition*sizeof(**raw));
  quant[0] = alloca(ch*partition*sizeof(**quant));
  floor[0] = alloca(ch*partition*sizeof(**floor));
  res[0]   = alloca(ch*partition*sizeof(**res));
  flag[0]  = alloca(ch*partition*sizeof(**flag));

  for(i=1;i<ch;i++){
    raw[i]   = &raw[0][partition*i];
    quant[i] = &quant[0][partition*i];
    floor[i] = &floor[0][partition*i];
    res[i]   = &res[0][partition*i];
    flag[i]  = &flag[0][partition*i];
  }

  for(i=0;i<ch+vi->coupling_steps;i++)
    acc[i]=0.f;

  // limit of rephase
  if(prepoint_x < prepoint) prepoint_x=prepoint;
  if(postpoint_x < prepoint) postpoint_x=prepoint;

  // set initial val for M6
  for(i=0;i<vi->coupling_steps;i++){
    side_resdef[i] = -1.f;
  }

  // set phase ratio for M6
  if(vi->coupling_steps==1) prae=0.34;
  else prae=0.825;


  // processing by every partition
  for(i=0,pi=0;i<lowpassr;i+=partition,pi++){
    int k,j,jn = partition > n-i ? n-i : partition;
    int step,track = 0;

    memcpy(nz,nonzero,sizeof(*nz)*ch);

    /* prefill */
    memset(flag[0],0,ch*partition*sizeof(**flag)); // reset stereo flag
    for(k=0;k<ch;k++){
      int *iout = &iwork[k][i];
      if(nz[k]){

        for(j=0;j<jn;j++){
          // compute floor mag
          floor[k][j] = FLOOR1_fromdB_LOOKUP[iout[j]];
        }

        // compute residue
        flag_lossless(limit,prepoint,postpoint,prepoint_x,postpoint_x,
                      res[k], &mdct[k][i],&enpeak[k][i],floor[k],flag[k],i,jn);

        for(j=0;j<jn;j++){
          // initial setting for quant/raw
          quant[k][j] = raw[k][j] = mdct[k][i+j]*mdct[k][i+j];
          if(mdct[k][i+j]<0.f) raw[k][j]*=-1.f;
          floor[k][j]*=floor[k][j];
        }

        // per-channel noise normalization
        // for lossless or mono mode
        acc[track]=noise_normalize(p,limit,raw[k],quant[k],floor[k],res[k],NULL,acc[track],nepeak[k][pi],i,jn,iout);

      }else{
        for(j=0;j<jn;j++){
          floor[k][j] = 1e-10f;
          raw[k][j] = 0.f;
          quant[k][j] = 0.f;
          res[k][j] = 0.f;
          flag[k][j] = 0;
          iout[j]=0;
        }
        acc[track]=0.f;
      }
      track++;
    }

    /* coupling */
    for(step=0;step<vi->coupling_steps;step++){
      int Mi = vi->coupling_mag[step];
      int Ai = vi->coupling_ang[step];
      int *iM = &iwork[Mi][i];
      int *iA = &iwork[Ai][i];
      float *reM = raw[Mi];
      float *reA = raw[Ai];
      float *qeM = quant[Mi];
      float *qeA = quant[Ai];
      float *floorM = floor[Mi];
      float *floorA = floor[Ai];
      float *resM = res[Mi];
      float *resA = res[Ai];
      int *fM = flag[Mi];
      int *fA = flag[Ai];
      int pointflag=0;

      if(nz[Mi] || nz[Ai]){
        nz[Mi] = nz[Ai] = 1;

        /** @ M6 MAIN **
            The threshold of a stereo is changed dynamically. Ver3
            by Aoyumi @ 2010/12/31
        */
        /* In the case of specific depth coupling, invalidate this. */
        if(p->tonefix_end>i){
          int rp=0;
          int pp=0;
          int ap;
          float residue_def=0;

          // calculate phase ratio of audio energy and deflection of residue.
          for(j=0;j<jn;j++){
            if(existe(resM[j],0.5) || existe(resA[j],0.5)){
              if(refer_phase(reM[j],reA[j])){
                rp++;
              }else pp++;
              residue_def+=fabs(fabs(resM[j])-fabs(resA[j]));
            }
          }
          ap=rp+pp;

          // based on a calculation result, put up a lossless flag.
          if(ap!=0){
            // deflection of residue
            float temp_def=residue_def=residue_def/ap; // normalization
            if(side_resdef[step]>0)residue_def=temp_def*0.5 + side_resdef[step]*0.5;
            side_resdef[step]=temp_def;
            if(residue_def>1.f){
              for(j=0;j<jn;j++){
                if(fM[j]==-1 || fA[j]==-1) fM[j]=1;
              }
            }
            // phase ratio of audio energy
            if((float)rp/ap >= prae){
              for(j=0;j<jn;j++){
                if((fM[j]==-1 || fA[j]==-1) && refer_phase(reM[j],reA[j])) fM[j]=1;
              }
            }
          }else side_resdef[step]=-1.f;
        }

        for(j=0;j<jn;j++){

          if(j<sliding_lowpass-i){
            if(fM[j]==1 || fA[j]==1){
              /* lossless coupling */

              reM[j] = fabs(reM[j])+fabs(reA[j]);
              qeM[j] = qeM[j]+qeA[j];
              fM[j]=fA[j]=1;

              lossless_couplingf(&resM[j], &resA[j]);

              /* couple iM/iA */
              lossless_coupling(&iM[j], &iA[j]);

            }else{
              /* lossy (point) coupling */
              // aotuv hypot
              float hpL;
              float hpH;
              if(vi->coupling_steps==1 || step==3){// needed 'step==3' is for 5.1 channel coupling.
                hpL=.18f;  hpH=.12f;
              }else{
                hpL=.18f;  hpH=.04f;
              }
              if(j<limit-i){
                reM[j]=min_indemnity_dipole_hypot(reM[j], reA[j], hpL);
              }else{
                reM[j]=min_indemnity_dipole_hypot(reM[j], reA[j], hpH);
              }

              // aotuv hypot (sub)
              //reM[j]=min_indemnity_dipole_hypotH(reM[j], reA[j]);

              // original hypot
              /*if(j<limit-i){
                // dipole
                reM[j] += reA[j];
                qeM[j] = fabs(reM[j]);
              }else{
                //elliptical
                if(reM[j]+reA[j]<0){
                  reM[j] = - (qeM[j] = (fabs(reM[j])+fabs(reA[j])));
                }else{
                  reM[j] =   (qeM[j] = (fabs(reM[j])+fabs(reA[j])));
                }
              }*/

              qeM[j]=fabs(reM[j]);
              reA[j]=qeA[j]=0.f;
              fA[j]=1;
              iA[j]=0;
              resA[j]=0;

              if((nepeak[Mi][pi]<-0.5) || (nepeak[Ai][pi]<-0.5)){
                nepeak[Mi][pi]=-1; // noise normalization is disable
              }else{
                nepeak[Mi][pi]=min(nepeak[Mi][pi], nepeak[Ai][pi]);
              }

              // set flag
              pointflag|=1;
            }
          }/*else{
              iM[j]=0;
              iA[j]=0;
          }*/
          floorM[j]=floorA[j]=floorM[j]+floorA[j];
        }
        /* normalize the resulting mag vector (for point stereo) */
        if(pointflag)
          acc[track]=noise_normalize(p,limit,raw[Mi],quant[Mi],floor[Mi],res[Mi],flag[Mi],acc[track],nepeak[Mi][pi],i,jn,iM);
        track++;
      }
    }
  }

  if(lowpassr<n){
    int j, block=n-lowpassr;
    for(j=0;j<ch;j++){
      memset(iwork[j]+lowpassr, 0, sizeof(**iwork)*block);
    }
  }

  for(i=0;i<vi->coupling_steps;i++){
    /* make sure coupling a zero and a nonzero channel results in two
       nonzero channels. */
    if(nonzero[vi->coupling_mag[i]] ||
       nonzero[vi->coupling_ang[i]]){
      nonzero[vi->coupling_mag[i]]=1;
      nonzero[vi->coupling_ang[i]]=1;
    }
  }
}

/*  aoTuV M5
    noise_compand_level of low frequency is determined from the level of high frequency.
    by Aoyumi @ 2005/09/14

    return value
    [normal compander] 0 <> 1.0 [high compander]
    negative value are disable
*/
float lb_loudnoise_fix(const vorbis_look_psy *p,
                       float noise_compand_level,
                       const float *logmdct,
                       const int block_mode,
                       const int lW_block_mode){

  int i, n=p->n, nq1=p->n25p, nq3=p->n75p;
  double hi_th=0;

  if(p->m_val < 0.5)return(-1); /* 48/44.1/32kHz only */
  if(p->vi->normal_thresh>.45)return(-1); /* under q3 */

  /* There is a specific limit for a threshold calculation. */
  if( !((block_mode==2 && lW_block_mode==3) || (block_mode==3 && lW_block_mode==2)) )return(noise_compand_level);

  /* calculation of a threshold. */
  for(i=nq1; i<nq3; i++){
    if(logmdct[i]>-130)hi_th += logmdct[i];
    else hi_th += -130;
  }
  hi_th /= n;

  /* calculation of a high_compand_level */
  if(hi_th > -40.) noise_compand_level=-1;
  else if(hi_th < -50.) noise_compand_level=1.;
  else noise_compand_level=1.-((hi_th+50)/10);

  return(noise_compand_level);
}
