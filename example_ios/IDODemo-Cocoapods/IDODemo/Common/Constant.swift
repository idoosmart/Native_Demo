//
//  File.swift
//  IDODemo
//
//  Created by cyf on 2025/3/18.
//

import Foundation
import protocol_channel

let IDODataTypDict: [IDODataType: String] = [
    IDODataType.none: "--",
    /// 总响应时间
    /// Overall response time
    IDODataType.overallResponseTime: "overallResponseTime",
    /// 距离类
    /// Distance category
    IDODataType.distance: "distance",
    /// 海拔类
    /// Elevation category
    IDODataType.elevation: "elevation",
    /// 配速类
    /// Pace category
    IDODataType.pace: "pace",
    /// 速度类
    /// Speed category
    IDODataType.speed: "speed",
    /// 心率类
    /// Heart rate category
    IDODataType.heartRate: "heartRate",
    /// 功率类
    /// Power category
    IDODataType.power: "power",
    /// 步频类
    /// Cadence category
    IDODataType.cadence: "cadence",
    /// 跑步类
    /// Running category
    IDODataType.runningEconomy: "runningEconomy",
    /// 跑步健身类
    /// Running fitness category
    IDODataType.runningFitness: "runningFitness",
    /// 时间类
    /// Time category
    IDODataType.time: "time",
    /// 其他类
    /// Other category
    IDODataType.other: "other"
]
    
let IDODataSubTypDict: [IDODataSubType: String]  = [
    IDODataSubType.none: "--",
    IDODataSubType.overallResponseTimeOverall:"Overall Response Time",
    IDODataSubType.distanceTotalDistance:"Total Distance",
    IDODataSubType.distanceCurrentLapDistance:"Current Lap Distance",
    IDODataSubType.distanceLastLapDistance:"Last Lap Distance",
    IDODataSubType.elevationElevation:"Elevation",
    IDODataSubType.elevationTotalAscent:"Total Ascent",
    IDODataSubType.elevationLapAscent:"Lap Ascent",
    IDODataSubType.elevationLastLapAscent:"Last Lap Ascent",
    IDODataSubType.elevationTotalDescent:"Total Descent",
    IDODataSubType.elevationLapDescent:"Lap Descent",
    IDODataSubType.elevationLastLapDescent:"Last Lap Descent",
    IDODataSubType.elevationGrade:"Grade",
    IDODataSubType.pacePace:"Pace",
    IDODataSubType.paceAveragePace:"Average Pace",
    IDODataSubType.paceLapPace:"Lap Pace",
    IDODataSubType.paceLastLapPace:"Last Lap Pace",
    IDODataSubType.paceEffortPace:"Effort Pace",
    IDODataSubType.paceAverageEffortPace:"Average Effort Pace",
    IDODataSubType.paceLapEffortPace:"Lap Effort Pace",
    IDODataSubType.speedCurrentSpeed:"Speed",
    IDODataSubType.speedAverageSpeed:"Average Speed",
    IDODataSubType.speedMaximumSpeed:"Maximum Speed",
    IDODataSubType.speedLapSpeed:"Lap Speed",
    IDODataSubType.speedLastLapSpeed:"Last Lap Speed",
    IDODataSubType.speedVerticalSpeed:"Vertical Speed",
    IDODataSubType.speedAverageVerticalSpeed:"Average Vertical Speed",
    IDODataSubType.speedLapVerticalSpeed:"Lap Vertical Speed",
    IDODataSubType.heartRateHeartRate:"Heart Rate",
    IDODataSubType.heartRateHeartRateZone:"Heart Rate Zone",
    IDODataSubType.heartRateAverageHeartRate:"Average Heart Rate",
    IDODataSubType.heartRateMaxHeartRate:"Max Heart Rate",
    IDODataSubType.heartRateLapHeartRate:"Lap Heart Rate",
    IDODataSubType.heartRateLastLapHeartRate:"Last Lap Heart Rate",
    IDODataSubType.heartRateHeartRateReserve:"Heart Rate Reserve",
    IDODataSubType.powerPower:"Power",
    IDODataSubType.powerAveragePower:"Average Power",
    IDODataSubType.powerLapPower:"Lap Power",
    IDODataSubType.power3sAveragePower:"3s Average Power",
    IDODataSubType.power10sAveragePower:"10s Average Power",
    IDODataSubType.power30sAveragePower:"",
    IDODataSubType.cadenceCadence:"Cadence",
    IDODataSubType.cadenceAverageCadence:"Average Cadence",
    IDODataSubType.cadenceLapCadence:"Lap Cadence",
    IDODataSubType.cadenceLastLapCadence:"Last Lap Cadence",
    IDODataSubType.runningEconomyStrideLength:"Stride Length",
    IDODataSubType.runningEconomyAverageStrideLength:"Average Stride Length",
    IDODataSubType.runningEconomyLapStridoLength:"Lap Strido Length",
    IDODataSubType.runningFitnessTrainingLoad:"Training Load",
    IDODataSubType.runningFitnessAerobicTrainingEffect:"Aerobic Training Effect",
    IDODataSubType.runningFitnessAnaerobicTrainingEfect:"Anaerobic Training Efect",
    IDODataSubType.runningFitnessCalorie:"Calorie",
    IDODataSubType.timeActivityTime:"Activity Time",
    IDODataSubType.timeTotalTime:"Total Time",
    IDODataSubType.timeCurrentTime:"Current Time",
    IDODataSubType.timeTimeToSunriseSunset:"Time To Sunrise Sunset",
    IDODataSubType.timeLapTime:"Lap Time",
    IDODataSubType.timeLastLapTime:"Last Lap Time",
    IDODataSubType.otherVO2max:"Vo2max",
    IDODataSubType.otherBatteryLevel:"Battery Level",
    IDODataSubType.otherBatteryLifeBasedOnSoc:"Battery Life Based On Soc"
]

