/*----------------------------------------------------------------------------//
!short: SAYCLICK  */

#xcommand REDEFINE SAYCLICK [<oSay>] ;
             [ <label: PROMPT, VAR> <cText> ] ;
             [ PICTURE <cPict> ] ;
             [ ID <nId> ] ;
             [ <dlg: OF,WINDOW,DIALOG > <oWnd> ] ;
             [ <color: COLOR,COLORS > <nClrText> [,<nClrBack> ] ] ;
             [ <update: UPDATE > ] ;
             [ ON [ LEFT ] DBLCLICK <uLDblClick> ] ;
             [ FONT <oFont> ] ;
       => ;
          [ <oSay> := ] TSayClick():ReDefine( <nId>, <{cText}>, <oWnd>, ;
                        <cPict>, <nClrText>, <nClrBack>, <.update.>, <oFont> ,<{uLDblClick}>)

#xcommand @ <nRow>, <nCol> SAYCLICK [ <oSay> <label: PROMPT,VAR > ] <cText> ;
             [ PICTURE <cPict> ] ;
             [ <dlg: OF,WINDOW,DIALOG > <oWnd> ] ;
             [ FONT <oFont> ]  ;
             [ <lCenter: CENTERED, CENTER > ] ;
             [ <lRight:  RIGHT >    ] ;
             [ ON [ LEFT ] DBLCLICK <uLDblClick> ] ;
             [ <lBorder: BORDER >   ] ;
             [ <lPixel: PIXEL, PIXELS > ] ;
             [ <color: COLOR,COLORS > <nClrText> [,<nClrBack> ] ] ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ <design: DESIGN >  ] ;
             [ <update: UPDATE >  ] ;
             [ <lShaded: SHADED, SHADOW > ] ;
             [ <lBox:    BOX   >  ] ;
             [ <lRaised: RAISED > ] ;
      => ;
          [ <oSay> := ] TSayClick():New( <nRow>, <nCol>, <{cText}>,;
             [<oWnd>], [<cPict>], <oFont>, <.lCenter.>, <.lRight.>, <.lBorder.>,;
             <.lPixel.>, <nClrText>, <nClrBack>, <nWidth>, <nHeight>,;
             <.design.>, <.update.>, <.lShaded.>, <.lBox.>, <.lRaised.>, <{uLDblClick}> )

