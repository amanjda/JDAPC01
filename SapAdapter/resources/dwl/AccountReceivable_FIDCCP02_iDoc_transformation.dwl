/*
* //==========================================================================
* //               Copyright 2020, Blue Yonder, Inc.
* //                         All Rights Reserved
* //
* //              THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF
* //                         BLUE YONDER, INC.
* //
* //
* //          The copyright notice above does not evidence any actual
* //               or intended publication of such source code.
* //
* //==========================================================================
*/
%dw 2.0
output application/xml
import * from dw::core::Strings
---
{
	(p('SAP.GL.AR_IDOCTYP_FID')) : {
		(payload.generalLedger map() -> {
			IDOC: {
				EDI_DC40: {
					IDOCTYP: p('SAP.GL.AR_IDOCTYP_FID'),
					MESTYP: p('SAP.GL.AR_MESTYP_FID'),
					SNDPOR: p('SAP.SNDPOR'),
					SNDPRT: p('SAP.SNDPRT'),
					SNDPRN: p('SAP.SNDPRN'),
					RCVPOR: p('SAP.RCVPOR'),
					RCVPRT: p('SAP.RCVPRT'),
					RCVPRN: p('SAP.RCVPRN'),
					DIRECT: 2
				},
				($.generalLedgerTransaction map (val,key)->{
					E1FIKPF @(SEGMENT: "00000" ++(1 +(key))): {
					
						BUKRS: if ( not isEmpty(val.organisationName) ) vars.orgCodeMap[(val.organisationName as String)] else "1000",
						BELNR: (if (val.transactionCategory default "" contains "REVERSED") "REVERSED" else ""),
						GJAHR: val.fiscalYear,
						BLART: "DR",
						BLDAT: $.creationDateTime  as DateTime  as String {
							format : "yyyy-MM-dd"
						},
						BUDAT: $.creationDateTime  as DateTime  as String {
							format : "yyyy-MM-dd"
						},
						MONAT: val.accountingPeriod,
						WWERT: $.creationDateTime  as DateTime  as String {
							format : "yyyy-MM-dd"
						},
						TCODE: "FB70",
						XBLNR: val.voucherDetail.referenceNumberValue,
						BKTXT: val.generalLedgerTransactionId,
						WAERS: val.amount.currencyCode,
						GLVOR: "RMRP",
						E1FISEG @(SEGMENT: "00000" ++ (2 +(key))): {
							BUZEI: "00" ++(1 +(key)),
							(if ((val.transactionCategory default "" ) contains "REVERSED") BSCHL : "12" else BSCHL: "01"),
							KOART: "D",
							(if ((val.transactionCategory default "" ) contains "REVERSED") SHKZG : "H" else SHKZG : "S"),
						    GSBER: "9900",
							WRBTR: val.amount.value,
							KOSTL: leftPad(val.costCenter,10,0),
							E1FINBU @(SEGMENT: "00000" ++(3 +(key))): {
								KUNNR: leftPad(val.accountParty.primaryId,10,0)
							}
						},
						E1FISEG @(SEGMENT: "00000" ++ (4 +(key))): {
							BUZEI: "00" ++(2 +(key)),
							(if ((val.transactionCategory default "" ) contains "REVERSED") BSCHL : "40" else BSCHL: "50"),
							KOART: "D",
							(if ((val.transactionCategory default "" ) contains "REVERSED") SHKZG : "S" else SHKZG: "H"),
							WRBTR: val.amount.value,
							HKONT: leftPad(val.generalLedgerAccountNumber,10,0),
							E1FINBU @(SEGMENT: "00000" ++(5 +(key))): {
								KUNNR: leftPad(val.accountParty.primaryId,10,0)
							}
						}
					}
				})
			}
		})
	}
}