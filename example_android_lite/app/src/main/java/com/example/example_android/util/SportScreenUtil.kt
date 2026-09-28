package com.example.example_android.util

import android.content.Context
import com.example.example_android.R
import com.idosmart.model.IDOSportScreenDataItemModel

object SportScreenUtil {
    //判断指定位是否为1
    fun isBitSet(number: Int, bitPosition: Int): Boolean {
        return ((number shr bitPosition) and 1) == 1
    }
    fun getContentByType(context: Context, type : Int): String {
        var contetent = type.toString()
        when (type) {
            1 -> contetent = context.getString(R.string.sport_data_type_overall_response_time)
            2 -> contetent = context.getString(R.string.sport_data_type_distance)
            3 -> contetent = context.getString(R.string.sport_data_type_elevation)
            4 -> contetent = context.getString(R.string.sport_data_type_pace)
            5 -> contetent = context.getString(R.string.sport_data_type_speed)
            6 -> contetent = context.getString(R.string.sport_data_type_heart_rate)
            7 -> contetent = context.getString(R.string.sport_data_type_power)
            8 -> contetent = context.getString(R.string.sport_data_type_cadence)
            9 -> contetent = context.getString(R.string.sport_data_type_running_economy)
            10 -> contetent = context.getString(R.string.sport_data_type_running_fitness)
            11 -> contetent = context.getString(R.string.sport_data_type_time)
            12 -> contetent = context.getString(R.string.sport_data_type_other)
        }
        return contetent
    }
//    fun getContent(context: Context, dataItem: IDOSportScreenDataItemModel): String {
//        var contetent = dataItem.dataType.toString() + "-" + dataItem.dataSubType
//        val type = dataItem.dataType
//        val subType = dataItem.dataSubType
//        when (type) {
//            1 -> if (subType == 1) {
//                contetent = context.getString(R.string.overall_response_time_overall_response_time)
//            }
//
//            2 -> if (subType == 1) {
//                contetent = context.getString(R.string.distance_total_distance)
//            } else if (subType == 2) {
//                contetent = context.getString(R.string.distance_current_lap_distance)
//            } else if (subType == 4) {
//                contetent = context.getString(R.string.distance_last_lap_distance)
//            }
//
//            3 -> if (subType == 1) {
//                contetent = context.getString(R.string.elevation_elevation)
//            } else if (subType == 2) {
//                contetent = context.getString(R.string.elevation_total_ascent)
//            } else if (subType == 4) {
//                contetent = context.getString(R.string.elevation_lap_ascent)
//            } else if (subType == 8) {
//                contetent = context.getString(R.string.elevation_last_lap_ascent)
//            } else if (subType == 16) {
//                contetent = context.getString(R.string.elevation_total_descent)
//            } else if (subType == 32) {
//                contetent = context.getString(R.string.elevation_lap_descent)
//            } else if (subType == 64) {
//                contetent = context.getString(R.string.elevation_last_lap_descent)
//            } else if (subType == 128) {
//                contetent = context.getString(R.string.elevation_grade)
//            }
//
//            4 -> if (subType == 1) {
//                contetent = context.getString(R.string.pace_pace)
//            } else if (subType == 2) {
//                contetent = context.getString(R.string.pace_average_pace)
//            } else if (subType == 4) {
//                contetent = context.getString(R.string.pace_lap_pace)
//            } else if (subType == 8) {
//                contetent = context.getString(R.string.pace_last_lap_pace)
//            } else if (subType == 16) {
//                contetent = context.getString(R.string.pace_effort_pace)
//            } else if (subType == 32) {
//                contetent = context.getString(R.string.pace_average_effort_pace)
//            } else if (subType == 64) {
//                contetent = context.getString(R.string.pace_lap_effort_pace)
//            }
//
//            5 -> if (subType == 1) {
//                contetent = context.getString(R.string.speed_speed)
//            } else if (subType == 2) {
//                contetent = context.getString(R.string.speed_average_speed)
//            } else if (subType == 4) {
//                contetent = context.getString(R.string.speed_maximum_speed)
//            } else if (subType == 8) {
//                contetent = context.getString(R.string.speed_lap_speed)
//            } else if (subType == 16) {
//                contetent = context.getString(R.string.speed_last_lap_speed)
//            } else if (subType == 32) {
//                contetent = context.getString(R.string.speed_vertical_speed)
//            } else if (subType == 64) {
//                contetent = context.getString(R.string.speed_average_vertical_speed)
//            } else if (subType == 128) {
//                contetent = context.getString(R.string.speed_lap_vertical_speed)
//            }
//
//            6 -> if (subType == 1) {
//                contetent = context.getString(R.string.heart_rate_heart_rate)
//            } else if (subType == 2) {
//                contetent = context.getString(R.string.heart_rate_heart_rate_zone)
//            } else if (subType == 4) {
//                contetent = context.getString(R.string.heart_rate_average_heart_rate)
//            } else if (subType == 8) {
//                contetent = context.getString(R.string.heart_rate_max_heart_rate)
//            } else if (subType == 16) {
//                contetent = context.getString(R.string.heart_rate_lap_heart_rate)
//            } else if (subType == 32) {
//                contetent = context.getString(R.string.heart_rate_last_lap_heart_rate)
//            } else if (subType == 64) {
//                contetent = context.getString(R.string.heart_rate_heart_rate_reserve)
//            }
//
//            7 -> if (subType == 1) {
//                contetent = context.getString(R.string.power_power)
//            } else if (subType == 2) {
//                contetent = context.getString(R.string.power_average_power)
//            } else if (subType == 4) {
//                contetent = context.getString(R.string.power_lap_power)
//            } else if (subType == 8) {
//                contetent = context.getString(R.string.power_3s_average_power)
//            } else if (subType == 16) {
//                contetent = context.getString(R.string.power_10s_average_power)
//            } else if (subType == 32) {
//                contetent = context.getString(R.string.power_30s_average_power)
//            }
//
//            8 -> if (subType == 1) {
//                contetent = context.getString(R.string.cadence_cadence)
//            } else if (subType == 2) {
//                contetent = context.getString(R.string.cadence_average_cadence)
//            } else if (subType == 4) {
//                contetent = context.getString(R.string.cadence_lap_cadence)
//            } else if (subType == 8) {
//                contetent = context.getString(R.string.cadence_last_lap_cadence)
//            }
//
//            9 -> if (subType == 1) {
//                contetent = context.getString(R.string.running_economy_stride_length)
//            } else if (subType == 2) {
//                contetent = context.getString(R.string.running_economy_average_stride_length)
//            } else if (subType == 4) {
//                contetent = context.getString(R.string.running_economy_lap_strido_length)
//            }
//
//            10 -> if (subType == 1) {
//                contetent = context.getString(R.string.running_fitness_training_load)
//            } else if (subType == 2) {
//                contetent = context.getString(R.string.running_fitness_aerobic_training_effect)
//            } else if (subType == 4) {
//                contetent = context.getString(R.string.running_fitness_anaerobic_training_efect)
//            } else if (subType == 8) {
//                contetent = context.getString(R.string.running_fitness_calorie)
//            }
//
//            12 -> if (subType == 1) {
//                contetent = context.getString(R.string.other_vo2max)
//            } else if (subType == 2) {
//                contetent = context.getString(R.string.other_battery_level)
//            } else if (subType == 4) {
//                contetent = context.getString(R.string.other_battery_life_based_on_soc)
//            }
//        }
//        return contetent
//    }
}