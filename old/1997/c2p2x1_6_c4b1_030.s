
; c2p2x1_6_c4b1

	IFND	BPLX
BPLX	EQU	320
	ENDC
	IFND	BPLY
BPLY	EQU	256
	ENDC
	IFND	BPLSIZE
BPLSIZE	EQU	BPLX*BPLY/8
	ENDC
	IFND	CHUNKYXMAX
CHUNKYXMAX EQU	BPLX
	ENDC
	IFND	CHUNKYYMAX
CHUNKYYMAX EQU	BPLY
	ENDC

	section	c2p,code

; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	(scroffsx) [screen-pixels]
; d3.w	scroffsy [screen-pixels]
; d4.w	(rowlen) [bytes] -- offset between one row and the next in a bpl
; d5.l	bplsize [bytes] -- offset between one row in one bpl and the next bpl

c2p2x1_6_c4b1_init
	movem.l	d2-d3,-(sp)
	lea	c2p_datanew(pc),a0
	andi.l	#$ffff,d0
	move.l	d5,c2p_bplsize-c2p_data(a0)
	move.w	d3,d2
	mulu.w	d0,d2
	lsr.l	#2,d2
	move.l	d2,c2p_scroffs-c2p_data(a0)
	add.w	d1,d3
	mulu.w	d0,d3
	lsr.l	#2,d3
	subq.w	#2,d3
	move.l	d3,c2p_scroffs2-c2p_data(a0)
	mulu.w	d0,d1
	move.l	d1,c2p_pixels-c2p_data(a0)
	lsr.l	#2,d1
	move.l	d1,c2p_pixels4-c2p_data(a0)
	lsr.l	#2,d1
	move.l	d1,c2p_pixels16-c2p_data(a0)
	movem.l	(sp)+,d2-d3
	rts

c2p_blitcleanup
	st	c2p_blitfin-c2p_bltnode(a1)
	sf	c2p_blitactive-c2p_bltnode(a1)
	rts

c2p_waitblit
	tst.b	c2p_blitactive(pc)
	beq.s	.n
.y	tst.b	c2p_blitfin(pc)
	beq.s	.y
.n	rts

; a0	c2pscreen
; a1	bitplanes

c2p2x1_6_c4b1
	movem.l	d2-d7/a2-a6,-(sp)

	move.w	#.x2-.x,d0
	bsr.s	c2p_waitblit
	bsr	c2p_copyinitblock

	lea	c2p_data(pc),a2
	move.l	a1,c2p_screen-c2p_data(a2)

	lea	c2p_blitbuf,a1

	move.l	#$33333333,d4
	move.l	#$0f0f0f0f,d5
	move.l	#$00ff00ff,d6

	move.l	c2p_pixels-c2p_data(a2),a2
	add.l	a0,a2
	cmpa.l	a0,a2
	beq	.none

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3

	move.w	d2,d7			; Swap 16x2
	move.w	d0,d2
	swap	d2
	move.w	d2,d0
	move.w	d7,d2

	move.w	d3,d7
	move.w	d1,d3
	swap	d3
	move.w	d3,d1
	move.w	d7,d3

	move.l	d2,d7			; Swap 4x2
	lsr.l	#4,d7
	eor.l	d0,d7
	and.l	d5,d7
	eor.l	d7,d0
	lsl.l	#4,d7
	eor.l	d7,d2

	move.l	d3,d7
	lsr.l	#4,d7
	eor.l	d1,d7
	and.l	d5,d7
	eor.l	d7,d1
	lsl.l	#4,d7
	eor.l	d7,d3

	bra.s	.start
.x
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3

	move.l	d7,(a1)+

	move.w	d2,d7			; Swap 16x2
	move.w	d0,d2
	swap	d2
	move.w	d2,d0
	move.w	d7,d2

	move.w	d3,d7
	move.w	d1,d3
	swap	d3
	move.w	d3,d1
	move.w	d7,d3

	move.l	d2,d7			; Swap 4x2
	lsr.l	#4,d7
	eor.l	d0,d7
	and.l	d5,d7
	move.l	a3,(a1)+
	eor.l	d7,d0
	lsl.l	#4,d7
	eor.l	d7,d2

	move.l	d3,d7
	lsr.l	#4,d7
	eor.l	d1,d7
	and.l	d5,d7
	eor.l	d7,d1
	lsl.l	#4,d7
	eor.l	d7,d3
.start

	move.l	d1,d7			; Swap 8x1, part 1
	lsr.l	#8,d7
	eor.l	d0,d7
	and.l	d6,d7
	eor.l	d7,d0
	lsl.l	#8,d7
	eor.l	d7,d1

	lsl.l	#2,d0			; Swap/Merge 2x1, part 1
	or.l	d1,d0
	move.l	d0,(a1)+

	move.l	d3,d7			; Swap 8x1, part 2
	lsr.l	#8,d7
	eor.l	d2,d7
	and.l	d6,d7
	eor.l	d7,d2
	lsl.l	#8,d7
	eor.l	d7,d3

	move.l	d3,d7			; Swap/Merge 2x1, part 2
	lsr.l	#2,d7
	eor.l	d2,d7
	and.l	d4,d7
	eor.l	d7,d2
	lsl.l	#2,d7
	eor.l	d3,d7

	move.l	d2,a3

	cmp.l	a0,a2
	bne.s	.x
.x2
	move.l	d7,(a1)+
	move.l	a3,(a1)+

	lea	c2p_data(pc),a2
	sf	c2p_blitfin-c2p_data(a2)
	st	c2p_blitactive-c2p_data(a2)
	lea	c2p_bltnode(pc),a1
	move.l	#c2p2x1_6_c4b1_51,c2p_bltroutptr-c2p_bltnode(a1)
	jsr	qblit

.none
	movem.l	(sp)+,d2-d7/a2-a6
	rts

c2p2x1_6_c4b1_51
	move.w	#-1,bltafwm(a0)
	move.w	#-1,bltalwm(a0)
	move.l	#c2p_blitbuf+4,bltapt(a0)
	move.l	#c2p_blitbuf+4,bltbpt(a0)
	move.l	c2p_bplsize-c2p_bltnode(a1),d0
	add.l	c2p_screen-c2p_bltnode(a1),d0
	add.l	c2p_scroffs-c2p_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	#8,bltamod(a0)
	move.w	#8,bltbmod(a0)
	move.w	#0,bltdmod(a0)
	move.w	#$aaaa,bltcdat(a0)
	move.w	#$0de4,bltcon0(a0)
	move.w	#$1000,bltcon1(a0)
	move.w	c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
	move.w	#2,bltsizh(a0)
	move.l	#c2p2x1_6_c4b1_52,c2p_bltroutptr-c2p_bltnode(a1)
	rts

c2p2x1_6_c4b1_52
	move.l	#c2p_blitbuf+8,bltapt(a0)
	move.l	#c2p_blitbuf+8,bltbpt(a0)
	move.l	c2p_bplsize-c2p_bltnode(a1),d0
	add.l	d0,d0
	add.l	c2p_bplsize-c2p_bltnode(a1),d0
	add.l	c2p_screen-c2p_bltnode(a1),d0
	add.l	c2p_scroffs-c2p_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
	move.w	#2,bltsizh(a0)
	move.l	#c2p2x1_6_c4b1_53,c2p_bltroutptr-c2p_bltnode(a1)
	rts

c2p2x1_6_c4b1_53
	move.l	#c2p_blitbuf,bltapt(a0)
	move.l	#c2p_blitbuf,bltbpt(a0)
	move.l	c2p_bplsize-c2p_bltnode(a1),d0
	lsl.l	#2,d0
	add.l	c2p_bplsize-c2p_bltnode(a1),d0
	add.l	c2p_screen-c2p_bltnode(a1),d0
	add.l	c2p_scroffs-c2p_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
	move.w	#2,bltsizh(a0)
	move.l	#c2p2x1_6_c4b1_54,c2p_bltroutptr-c2p_bltnode(a1)
	rts

c2p2x1_6_c4b1_54
	move.l	#c2p_blitbuf-6,d0
	add.l	c2p_pixels-c2p_bltnode(a1),d0
	sub.l	c2p_pixels4-c2p_bltnode(a1),d0
	move.l	d0,bltapt(a0)
	move.l	d0,bltbpt(a0)
	move.l	c2p_screen-c2p_bltnode(a1),d0
	add.l	c2p_scroffs2-c2p_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	#$1de4,bltcon0(a0)
	move.w	#$0002,bltcon1(a0)
	move.w	c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
	move.w	#2,bltsizh(a0)
	move.l	#c2p2x1_6_c4b1_55,c2p_bltroutptr-c2p_bltnode(a1)
	rts

c2p2x1_6_c4b1_55
	move.l	#c2p_blitbuf-2,d0
	add.l	c2p_pixels-c2p_bltnode(a1),d0
	sub.l	c2p_pixels4-c2p_bltnode(a1),d0
	move.l	d0,bltapt(a0)
	move.l	d0,bltbpt(a0)
	move.l	c2p_bplsize-c2p_bltnode(a1),d0
	add.l	d0,d0
	add.l	c2p_screen-c2p_bltnode(a1),d0
	add.l	c2p_scroffs2-c2p_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	#$1de4,bltcon0(a0)
	move.w	#$0002,bltcon1(a0)
	move.w	c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
	move.w	#2,bltsizh(a0)
	move.l	#c2p2x1_6_c4b1_56,c2p_bltroutptr-c2p_bltnode(a1)
	rts

c2p2x1_6_c4b1_56
	move.l	#c2p_blitbuf-10,d0
	add.l	c2p_pixels-c2p_bltnode(a1),d0
	sub.l	c2p_pixels4-c2p_bltnode(a1),d0
	move.l	d0,bltapt(a0)
	move.l	d0,bltbpt(a0)
	move.l	c2p_bplsize-c2p_bltnode(a1),d0
	lsl.l	#2,d0
	add.l	c2p_screen-c2p_bltnode(a1),d0
	add.l	c2p_scroffs2-c2p_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	#$1de4,bltcon0(a0)
	move.w	#$0002,bltcon1(a0)
	move.w	c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
	move.w	#2,bltsizh(a0)
	move.l	#c2p2x1_6_c4b1_51,c2p_bltroutptr-c2p_bltnode(a1)
	moveq	#0,d0
	rts

c2p_copyinitblock
	movem.l	a0-a1,-(sp)
	lea	c2p_datanew,a0
	lea	c2p_data,a1
	moveq	#16-1,d0
.copy	move.l	(a0)+,(a1)+
	dbf	d0,.copy
	movem.l	(sp)+,a0-a1
	rts

	cnop 0,4
c2p_bltnode
	dc.l	0
c2p_bltroutptr
	dc.l	0
	dc.b	$40,0
	dc.l	0
c2p_bltroutcleanup
	dc.l	c2p_blitcleanup
c2p_blitfin dc.b 0
c2p_blitactive dc.b 0

	cnop	0,4
c2p_data
c2p_screen dc.l	0
c2p_scroffs dc.l 0
c2p_scroffs2 dc.l 0
c2p_bplsize dc.l 0
c2p_pixels dc.l 0
c2p_pixels4 dc.l 0
c2p_pixels16 dc.l 0
	ds.l	16

	cnop 0,4
c2p_datanew
	ds.l	16

	section	bss_c,bss_c

c2p_blitbuf
	ds.b	CHUNKYXMAX*CHUNKYYMAX*3/4
