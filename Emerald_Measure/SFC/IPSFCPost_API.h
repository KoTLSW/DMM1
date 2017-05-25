/*
 *  IPSFCPost_API.h
 *  IPSFCPost
 *
 *  Created on 9/11/10.
 *  Copyright 2010 Apple Inc. All rights reserved.
 *
 */
#ifndef IPSFCPost__API__HH__
#define IPSFCPost__API__HH__

#define kDevice                             "Device"
#define kResult                             "Result"
#define kBuildInstallAttempted              "BuildInstallAttempted"
#define kDeviceApECID                       "kDevice:ApECID"
#define kDeviceBbSNUM                       "kDevice:BbSNUM"
#define kDeviceChipID                       "kDevice:ChipID"
#define kDeviceFGSN                         "kDevice:FGSN"
#define kBuildInstallAttemptedBuildTrain    "kBuildInstallAttempted:BuildTrain"
#define kBuildInstallAttemptedBuildNumber   "kBuildInstallAttempted:BuildNumber"
#define kBuildInstallAttemptedBuildVariant  "kBuildInstallAttempted:BuildVariant"
#define kBuildInstallAttemptedBuildVersion  "kBuildInstallAttempted:BuildVersion"
#define kBuildInstallAttemptedDeviceClass   "kBuildInstallAttempted:DeviceClass"
#define kRestoreSessionUUID                 "RestoreSessionUUID"
#define kRestoreStatus                      "RestoreStatus"
struct QRStruct {
    char * Qkey;
    char * Qval;
};

#ifdef WIN32
	#define EXPORT __declspec(dllexport)
#else
	#ifndef EXPORT
		#define EXPORT __attribute__((visibility("default")))
	#endif
#endif     //WIN32
//please check the IPSFC.log file for detailed errors. Check the bobcat spec. and samples for more details.
#ifdef __OBJC__

	#import <Foundation/Foundation.h>
	/* returns version string */
	EXPORT const char * SFCLibVersion(void);
	EXPORT const char * SFCServerVersion(void);
	EXPORT const char * SFCQueryHistory(const char * acpSerialNumber);
	EXPORT const char * SFCQueryRecordUnitCheck(const char * acpSerialNumber,const char * acpStationID);
    EXPORT const char * SFCQueryRecordUnitCheckEx(const char * acpSerialNumber,const char * acpStationID,struct QRStruct *apQRStruct[],int size);

    //For all the apis that require QRStruct, please add the size as number of items in the QRStruct.
	EXPORT int SFCAddRecord(const char * acpSerialNumber,struct QRStruct *apQRStruct[],int size);
    //SFCAddAttr requires at least 3 items start_time,mac_address and attribute you want to send
	EXPORT int SFCAddAttr(const char * acpSerialNumber,struct QRStruct *apQRStruct[],int size);
	EXPORT int SFCQueryRecord(const char * acpSerialNumber, struct QRStruct *apQRStruct[],int aiSize);
	EXPORT int SFCQueryRecordGetTestResult(const char * acpSerialNumber,const char * acpTestStationName,struct QRStruct *apQRStruct[], int size);
    EXPORT int SFCQueryRecordByStationName(const char * acpSerialNumber,const char * acpTestStationName,struct QRStruct *apQRStruct[], int size);
    EXPORT int SFCQueryRecordByStationID(const char * acpSerialNumber,const char * acpTestStationID,struct QRStruct *apQRStruct[], int size);

    EXPORT int SendIOSRestoreStatus  (struct QRStruct *apQRStruct[],int aiSize);
    EXPORT int SendIOSRestoreStatusSN(const char * acpSerialNumber, struct QRStruct *apQRStruct[],int aiSize);

	EXPORT	void FreeSFCBuffer(const char * cpBuffer);

#else /* __OBJC__ */



#ifdef __cplusplus
	extern "C" {
#endif

		
	/* returns version string */
	EXPORT const char * SFCLibVersion(void);
	EXPORT const char * SFCServerVersion(void);
	EXPORT const char * SFCQueryHistory(const char * acpSerialNumber);
	EXPORT const char * SFCQueryRecordUnitCheck(const char * acpSerialNumber,const char * acpStationID);
    EXPORT const char * SFCQueryRecordUnitCheckEx(const char * acpSerialNumber,const char * acpStationID,struct QRStruct *apQRStruct[],int size);

    //For all the apis that require QRStruct, please add the size as number of items in the QRStruct.
	EXPORT int SFCAddRecord(const char * acpSerialNumber,struct QRStruct *apQRStruct[],int size);
    //SFCAddAttr requires at least 3 items start_time,mac_address and attribute you want to send
    EXPORT int SFCAddAttr(const char * acpSerialNumber,struct QRStruct *apQRStruct[],int size);
	EXPORT int SFCQueryRecord(const char * acpSerialNumber, struct QRStruct *apQRStruct[],int aiSize);		
	EXPORT int SFCQueryRecordGetTestResult(const char * acpSerialNumber,const char * acpTestStationName,struct QRStruct *apQRStruct[], int size);
    EXPORT int SFCQueryRecordByStationName(const char * acpSerialNumber,const char * acpTestStationName,struct QRStruct *apQRStruct[], int size);
    EXPORT int SFCQueryRecordByStationID(const char * acpSerialNumber,const char * acpTestStationID,struct QRStruct *apQRStruct[], int size);

	EXPORT void FreeSFCBuffer(const char * cpBuffer);
    EXPORT int SendIOSRestoreStatus  (struct QRStruct *apQRStruct[],int aiSize);
    EXPORT int SendIOSRestoreStatusSN(const char * acpSerialNumber, struct QRStruct *apQRStruct[],int aiSize);


#ifdef __cplusplus
	}
#endif


#endif /* __OBJ__ */
#endif /* IPSFCPost__API__HH__ */

