package com.example.example_android.util;


import com.example.example_android.R;
import com.idosmart.model.IDODataSubType;
import com.idosmart.model.IDODataType;

import java.util.HashMap;

public class SportScreenSetUtil {
    public static HashMap<IDODataType,Integer> SPORT_DATA_S= new HashMap();
    static {
        SPORT_DATA_S.put(IDODataType.OVERALL_RESPONSE_TIME, R.string.sport_data_type_overall_response_time);
        SPORT_DATA_S.put(IDODataType.DISTANCE, R.string.sport_data_type_distance);
        SPORT_DATA_S.put(IDODataType.ELEVATION, R.string.sport_data_type_elevation);
        SPORT_DATA_S.put(IDODataType.PACE, R.string.sport_data_type_pace);
        SPORT_DATA_S.put(IDODataType.SPEED, R.string.sport_data_type_speed);
        SPORT_DATA_S.put(IDODataType.HEART_RATE, R.string.sport_data_type_heart_rate);
        SPORT_DATA_S.put(IDODataType.POWER, R.string.sport_data_type_power);
        SPORT_DATA_S.put(IDODataType.CADENCE, R.string.sport_data_type_cadence);
        SPORT_DATA_S.put(IDODataType.RUNNING_ECONOMY, R.string.sport_data_type_running_economy);
        SPORT_DATA_S.put(IDODataType.RUNNING_FITNESS, R.string.sport_data_type_running_fitness);
        SPORT_DATA_S.put(IDODataType.TIME, R.string.sport_data_type_time);
        SPORT_DATA_S.put(IDODataType.OTHER, R.string.sport_data_type_other);
    }

    public static HashMap<IDODataSubType,Integer> SPORT_DATA_S_SUB= new HashMap();

    static {
        SPORT_DATA_S_SUB.put(IDODataSubType.OVERALL_RESPONSE_TIME_OVERALL, R.string.overall_response_time_overall_response_time);
        SPORT_DATA_S_SUB.put(IDODataSubType.DISTANCE_TOTAL_DISTANCE, R.string.distance_total_distance);
        SPORT_DATA_S_SUB.put(IDODataSubType.DISTANCE_CURRENT_LAP_DISTANCE, R.string.distance_current_lap_distance);
        SPORT_DATA_S_SUB.put(IDODataSubType.DISTANCE_LAST_LAP_DISTANCE, R.string.distance_last_lap_distance);
        SPORT_DATA_S_SUB.put(IDODataSubType.ELEVATION_ELEVATION, R.string.elevation_elevation);
        SPORT_DATA_S_SUB.put(IDODataSubType.ELEVATION_TOTAL_ASCENT, R.string.elevation_total_ascent);
        SPORT_DATA_S_SUB.put(IDODataSubType.ELEVATION_LAP_ASCENT, R.string.elevation_lap_ascent);
        SPORT_DATA_S_SUB.put(IDODataSubType.ELEVATION_LAST_LAP_ASCENT, R.string.elevation_last_lap_ascent);
        SPORT_DATA_S_SUB.put(IDODataSubType.ELEVATION_TOTAL_DESCENT, R.string.elevation_total_descent);
        SPORT_DATA_S_SUB.put(IDODataSubType.ELEVATION_LAP_DESCENT, R.string.elevation_lap_descent);
        SPORT_DATA_S_SUB.put(IDODataSubType.ELEVATION_LAST_LAP_DESCENT, R.string.elevation_last_lap_descent);
        SPORT_DATA_S_SUB.put(IDODataSubType.ELEVATION_GRADE, R.string.elevation_grade);
        SPORT_DATA_S_SUB.put(IDODataSubType.PACE_PACE, R.string.pace_pace);
        SPORT_DATA_S_SUB.put(IDODataSubType.PACE_AVERAGE_PACE, R.string.pace_average_pace);
        SPORT_DATA_S_SUB.put(IDODataSubType.PACE_LAP_PACE, R.string.pace_lap_pace);
        SPORT_DATA_S_SUB.put(IDODataSubType.PACE_LAST_LAP_PACE, R.string.pace_last_lap_pace);
        SPORT_DATA_S_SUB.put(IDODataSubType.PACE_EFFORT_PACE, R.string.pace_effort_pace);
        SPORT_DATA_S_SUB.put(IDODataSubType.PACE_AVERAGE_EFFORT_PACE, R.string.pace_average_effort_pace);
        SPORT_DATA_S_SUB.put(IDODataSubType.PACE_LAP_EFFORT_PACE, R.string.pace_lap_effort_pace);
        SPORT_DATA_S_SUB.put(IDODataSubType.SPEED_CURRENT_SPEED, R.string.speed_speed);
        SPORT_DATA_S_SUB.put(IDODataSubType.SPEED_AVERAGE_SPEED, R.string.speed_average_speed);
        SPORT_DATA_S_SUB.put(IDODataSubType.SPEED_MAXIMUM_SPEED, R.string.speed_maximum_speed);
        SPORT_DATA_S_SUB.put(IDODataSubType.SPEED_LAP_SPEED, R.string.speed_lap_speed);
        SPORT_DATA_S_SUB.put(IDODataSubType.SPEED_LAST_LAP_SPEED, R.string.speed_last_lap_speed);
        SPORT_DATA_S_SUB.put(IDODataSubType.SPEED_VERTICAL_SPEED, R.string.speed_vertical_speed);
        SPORT_DATA_S_SUB.put(IDODataSubType.SPEED_AVERAGE_VERTICAL_SPEED, R.string.speed_average_vertical_speed);
        SPORT_DATA_S_SUB.put(IDODataSubType.SPEED_LAP_VERTICAL_SPEED, R.string.speed_lap_vertical_speed);
        SPORT_DATA_S_SUB.put(IDODataSubType.HEART_RATE_HEART_RATE, R.string.heart_rate_heart_rate);
        SPORT_DATA_S_SUB.put(IDODataSubType.HEART_RATE_HEART_RATE_ZONE, R.string.heart_rate_heart_rate_zone);
        SPORT_DATA_S_SUB.put(IDODataSubType.HEART_RATE_AVERAGE_HEART_RATE, R.string.heart_rate_average_heart_rate);
        SPORT_DATA_S_SUB.put(IDODataSubType.HEART_RATE_MAX_HEART_RATE, R.string.heart_rate_max_heart_rate);
        SPORT_DATA_S_SUB.put(IDODataSubType.HEART_RATE_LAP_HEART_RATE, R.string.heart_rate_lap_heart_rate);
        SPORT_DATA_S_SUB.put(IDODataSubType.HEART_RATE_LAST_LAP_HEART_RATE, R.string.heart_rate_last_lap_heart_rate);
        SPORT_DATA_S_SUB.put(IDODataSubType.HEART_RATE_HEART_RATE_RESERVE, R.string.heart_rate_heart_rate_reserve);
        SPORT_DATA_S_SUB.put(IDODataSubType.POWER_POWER, R.string.power_power);
        SPORT_DATA_S_SUB.put(IDODataSubType.POWER_AVERAGE_POWER, R.string.power_average_power);
        SPORT_DATA_S_SUB.put(IDODataSubType.POWER_LAP_POWER, R.string.power_lap_power);
        SPORT_DATA_S_SUB.put(IDODataSubType.POWER_3S_AVERAGE_POWER, R.string.power_3s_average_power);
        SPORT_DATA_S_SUB.put(IDODataSubType.POWER_10S_AVERAGE_POWER, R.string.power_10s_average_power);
        SPORT_DATA_S_SUB.put(IDODataSubType.POWER_30S_AVERAGE_POWER, R.string.power_30s_average_power);
        SPORT_DATA_S_SUB.put(IDODataSubType.CADENCE_CADENCE, R.string.cadence_cadence);
        SPORT_DATA_S_SUB.put(IDODataSubType.CADENCE_AVERAGE_CADENCE, R.string.cadence_average_cadence);
        SPORT_DATA_S_SUB.put(IDODataSubType.CADENCE_LAP_CADENCE, R.string.cadence_lap_cadence);
        SPORT_DATA_S_SUB.put(IDODataSubType.CADENCE_LAST_LAP_CADENCE, R.string.cadence_last_lap_cadence);
        SPORT_DATA_S_SUB.put(IDODataSubType.RUNNING_ECONOMY_STRIDE_LENGTH, R.string.running_economy_stride_length);
        SPORT_DATA_S_SUB.put(IDODataSubType.RUNNING_ECONOMY_AVERAGE_STRIDE_LENGTH, R.string.running_economy_average_stride_length);
        SPORT_DATA_S_SUB.put(IDODataSubType.RUNNING_ECONOMY_LAP_STRIDO_LENGTH, R.string.running_economy_lap_strido_length);
        SPORT_DATA_S_SUB.put(IDODataSubType.RUNNING_FITNESS_TRAINING_LOAD, R.string.running_fitness_training_load);
        SPORT_DATA_S_SUB.put(IDODataSubType.RUNNING_FITNESS_AEROBIC_TRAINING_EFFECT, R.string.running_fitness_aerobic_training_effect);
        SPORT_DATA_S_SUB.put(IDODataSubType.RUNNING_FITNESS_ANAEROBIC_TRAINING_EFECT, R.string.running_fitness_anaerobic_training_efect);
        SPORT_DATA_S_SUB.put(IDODataSubType.RUNNING_FITNESS_CALORIE, R.string.running_fitness_calorie);
        SPORT_DATA_S_SUB.put(IDODataSubType.TIME_ACTIVITY_TIME, R.string.time_activity_time);
        SPORT_DATA_S_SUB.put(IDODataSubType.TIME_TOTAL_TIME, R.string.time_total_time);
        SPORT_DATA_S_SUB.put(IDODataSubType.TIME_CURRENT_TIME, R.string.time_current_time);
        SPORT_DATA_S_SUB.put(IDODataSubType.TIME_TIME_TO_SUNRISE_SUNSET, R.string.time_time_to_sunrise_sunset);
        SPORT_DATA_S_SUB.put(IDODataSubType.TIME_LAP_TIME, R.string.time_lap_time);
        SPORT_DATA_S_SUB.put(IDODataSubType.TIME_LAST_LAP_TIME, R.string.time_last_lap_time);
        SPORT_DATA_S_SUB.put(IDODataSubType.OTHER_VO2MAX, R.string.other_vo2max);
        SPORT_DATA_S_SUB.put(IDODataSubType.OTHER_BATTERY_LEVEL, R.string.other_battery_level);
        SPORT_DATA_S_SUB.put(IDODataSubType.OTHER_BATTERY_LIFE_BASED_ON_SOC, R.string.other_battery_life_based_on_soc);
    }
}
