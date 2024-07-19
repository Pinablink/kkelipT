;-------------------------------------------------------------------------------
;       #######################***#################%%%%%%%##
;       #############********###############################
;       ###########*******#########****#%%%%################
;       ####*##*********####******###****#%%%########***####
;       #*************##************###***+*#%##############
;       #***********###***************##***++*%%%%##########
;       #####******###**********++***#####**++*%%%%%%#######
;       #####****####*********+++++**#####**+==*%%%%%%######
;       ####*****%###*********+++++***####**+=--%@@%%%######
;       ####****%%%#*#******++++++*+**###**+==-:+@@%%%%####%
;       %%###**#%%#####******++===++***#**++==---%@%%%##%%%%
;       %%######%%#######*****++===+***#*+===-::-*%%%%####%%
;       %######%%%#######*****+++==+***#*+--==:::=%%%%%%%%%%
;       %%#####%###########***+====++*##*+-----::-@%%%%%%%%%
;       %%#####%%%###########**+++=+*####**+==---=@%%%%%%%##
;       %%####*%%########************####**+=====*@%%%%%%%##
;       %#####*%%###*=-----=**++++++**=:----:.-=-#@%%%%%%%%%
;       ########%#*:=#%%%#*+:-***+**=:*#*++++-:.::%%%%%%%%%%
;       ######*-++:%@@@%%%%#*+.**+*--##=++*###+-.+:#%%%%%%%%
;       ######*.#:#%@@@@@@@%%#=:=--.**+*%@@@%@*-*.*:%%%%%%%%
;       ######*::=%#%@@@@@@%@%%.*+=-##%@@@@%@+:-%.--#%%%%@@@
;       #######*+-%%%#%%@@@@@@%.%#+:#@@@@@%+=:-+%.%%%%%%@@@@
;       ########*.#%%%######%%==#*+:+%%%##*+--+#-*%%%%%%%@@@
;       #########*:+%%%#####*--##*+#--*###*-=*+-*%%%%%%%%%%@
;       ###########+-=*#**+--+#%#*+#%*=--::::-+%%%%%%%%%%%%%
;       ############%#*+++*###%%%**#%##+-=-=#%%%%%%%%%%%%%%%
;       %%%%%########%%%%%%%###*+**#*#+--==%@%%%%%%%%%%%%%%%
;       %%%%%%########%%%%%%###*+=*#*++-:=%%%%%%%%%%%%%@%%%%
;       %%%%%%%%#%%%%%%%%%%%##*****#*==--*@%%%%%%%%%%%%%%%%%
;       %%%%%%%%%%%%%%%%%%%%%###*###+---+@@%%%%%%@@@@@@%%%%%
;       ##%%%%%%%%%%%%%%%%%%%######*=+--@@@@%%%%@@@@@@@@@@@@
;       ##%%%%%%%%%%%%%%%%%%%###**##+--*@@@@@%%%@@@@@@@@@@@@
;       #%%%%%%%%%%%%%%%%%%%%###*+#*=-=%%%%%%%%%%@@@@@@@@@@@
;       %%%%%%%%%%%%%%%%%%%#%#**+=*+-+*%%%%%%%%%%@@@@@@@@%%%
;       %%%%%%%%%%%%%%%%%%%##%%###*-*%*%%%@@@@@@@@@@@@@@%%%%
;       %%%%%%%%%%%%%%%%%%%##%%##%#+##+%%%%%%@@@@@@@@@@%%%%%
;       %%%%%%%%%%%%%%%%%%##*#%####+#*-%%@@@%%%@@@@@@@@%%%%%
;       %%%%%%%%%%%%%%%@%%##**%%%%**#*-+%%%%%%%%@@@%@@%%%%%%
;       %%%%@@@%%%%%%%@%####*+###%**#*-=*%%%%%%%%@@@%%%@%%%%
;       %%%@@@@@@%%%%%#**#%#*+***##***-+###%%%%%%%@@@@@@@%%%
;       %%%@@@@@@%%#**+**##**+*++*#+**-=#****#%%%%@@@@@@@@%%
;       %%@@@@@%##*******#***=+++**=+*+=*#*****##%%%@@%%%%%%
;       %@@@%%#**************+++**+=*+#*###**+****#%%%%%%%%%
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
            			.cdecls C,LIST,"msp430.h","./header/kkelipTH.h"
;-------------------------------------------------------------------------------
            			.def    RESET
;-------------------------------------------------------------------------------
            			.text
            			.retain
            			.retainrefs
;-------------------------------------------------------------------------------
RESET       			mov.w   #__STACK_END,SP
StopWDT     			mov.w   #WDTPW|WDTHOLD,&WDTCTL
						mov.b   &CALBC1_16MHZ,&BCSCTL1  ; Configurando para processar o rel�gio interno
                    	mov.b   &CALDCO_16MHZ,&DCOCTL   ; a 16MHz
						call    #CLEAR_REGISTER
                        call	#CLEAR_INTERNAL_RAM
                        mov.b   #003H,&QT_LED_N
;-------------------------------------------------------------------------------
; LOOP PRINCIPAL
;-------------------------------------------------------------------------------
firmware_on_led         call    #ON_LEDS
						nop
firmware_run            jmp		$
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
CLEAR_REGISTER
;-------------------------------------------------------------------------------
						mov.w    #00000H,R4
						mov.w    #00000H,R5
						mov.w    #00000H,R6
						mov.w    #00000H,R7
						mov.w    #00000H,R8
						mov.w    #00000H,R9
						mov.w    #00000H,R10
						mov.w    #00000H,R11
						mov.w    #00000H,R12
						mov.w    #00000H,R13
						mov.w    #00000H,R14
						mov.w    #00000H,R15
						ret
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
CLEAR_INTERNAL_RAM
;-------------------------------------------------------------------------------
                    	push.w   R4
                    	push.w   R5
                    	mov.w    #00000H,R5
                    	mov.w    #001F4H,R4
continue_clear_ram 		cmp.w    #00000H,R4
                    	jeq      end_clear_ram
                    	mov.b    #0FFH,0200H(R5)
                    	inc.w    R5
                    	dec.w    R4
                    	jmp      continue_clear_ram
end_clear_ram      		pop.w    R5
                    	pop.w    R4
                    	ret
;-------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------------
HOLD_ON_800_CYCLES ; Bloqueia o processamento da m�quina por 800 ciclos
;----------------------------------------------------------------------------------------------
						push.w   R15
						mov.w    #00109H,R15
ct_ho800				add.w    #0FFFFH,R15
						jc       ct_ho800
						pop.w    R15
						ret
;----------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
ON_LEDS
;-------------------------------------------------------------------------------
                        push.w   R5
                        push.w   R6
                        push.w   R7
                        mov.w    #00000H,R5
                        mov.b    &QT_LED_N,R5
						call     #INIT_SPI_COMM
						mov.w    #LED_CC_COLOR_DEFAULT,R6
						mov.w    #00000H,R7
						mov.b    #0003H,R7
on_leds_loop_main		cmp.b    #000H,R5
						jeq      fin_on_leds_loop_main
on_led_in_rgb_loop		cmp.b    #000H,R7
						jeq      fin_on_led_in_rgb_loop
						call     #SS_STRP
						dec.b    R7
						jmp      on_led_in_rgb_loop
fin_on_led_in_rgb_loop	mov.b    #0003H,R7
                        dec.b    R5
						jmp		 on_leds_loop_main
fin_on_leds_loop_main   nop
main_loop_on_leds       nop
						pop.w    R7
                        pop.w    R6
                        pop.w    R5
						ret
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
INIT_SPI_COMM
;-------------------------------------------------------------------------------
						bis.b    #080H,&P1SEL
						bis.b    #080H,&P1SEL2
						bis.b    #0A9H,&UCB0CTL0
						bis.b    #080H,&UCB0CTL1
						mov.b    #003H,&UCB0BR0
						clr.b    &UCB0BR1
						bic.b    #001H,&UCB0CTL1
						ret
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
SS_STRP ; Show Strip
;-------------------------------------------------------------------------------
						push.w   R14
						push.w   R15
						mov.w    #00000H,R4
						mov.w    #00000H,R14
						mov.w    #00000H,R15
						mov.b    &QT_LED_N,R4
;===============================================================================
                        mov.b    @R6+,R15
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
						mov.b    #080H,R14
bit_rr_r                cmp.b    #000H,R14
                       	jeq      bit_rr_0_ok
hold_on_spi_comm		bit.b    #008H,&IFG2
						jnc      hold_on_spi_comm
						nop
						bit.b    R14,R15
						jeq      bit_rr_off
						mov.b    #HIGH_CODE_WS2812,&UCB0TXBUF
						jmp      exec_rr
bit_rr_off              mov.b    #LOW_CODE_WS2812,&UCB0TXBUF
exec_rr					bic.b    #1,SR
						rrc.b    R14
						jmp      bit_rr_r
bit_rr_0_ok             nop
;===============================================================================
						pop.w    R15
						pop.w    R14
						ret
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;                                  DADOS FIXOS
;-------------------------------------------------------------------------------
;                                |G    |R   |B
;-------------------------------------------------------------------------------
LED_CC_COLOR_DEFAULT
						.byte    080H, 000H, 000H  ; Verde
						.byte    0FFH, 0FFH, 000H  ; Amarelo
						.byte    000H, 0FFH, 000H  ; Vermelho
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            			.global __STACK_END
            			.sect   .stack
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            			.sect   ".reset"
            			.short  RESET
;-------------------------------------------------------------------------------