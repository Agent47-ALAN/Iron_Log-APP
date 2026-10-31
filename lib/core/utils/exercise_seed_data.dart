import '../models/exercise.dart';

class ExerciseSeedData {
  static List<Exercise> get builtIn => [
      // ── Additional Chest ─────────────────────────────────────
    Exercise(id: 'smith_bench', name: 'Smith Machine Bench Press', muscleGroup: 'Chest', equipment: 'Smith Machine', secondaryMuscles: ['Triceps', 'Shoulders']),
    Exercise(id: 'incline_db_fly', name: 'Incline Dumbbell Fly', muscleGroup: 'Chest', equipment: 'Dumbbell'),
    Exercise(id: 'incline_pushup', name: 'Incline Push-Up', muscleGroup: 'Chest', equipment: 'Bodyweight'),
    Exercise(id: 'decline_pushup', name: 'Decline Push-Up', muscleGroup: 'Chest', equipment: 'Bodyweight'),
    Exercise(id: 'db_pullover_chest', name: 'Dumbbell Pullover', muscleGroup: 'Chest', equipment: 'Dumbbell'),

    // ── Additional Back ──────────────────────────────────────
    Exercise(id: 'straight_arm_pd', name: 'Straight Arm Pulldown', muscleGroup: 'Back', equipment: 'Cable'),
    Exercise(id: 'single_arm_cable_row', name: 'Single Arm Cable Row', muscleGroup: 'Back', equipment: 'Cable'),
    Exercise(id: 'rack_pull', name: 'Rack Pull', muscleGroup: 'Back', equipment: 'Barbell'),
    Exercise(id: 'landmine_row', name: 'Landmine Row', muscleGroup: 'Back', equipment: 'Barbell'),
    Exercise(id: 'single_landmine_row', name: 'Single Arm Landmine Row', muscleGroup: 'Back', equipment: 'Barbell'),
    Exercise(id: 'meadows_row', name: 'Meadows Row', muscleGroup: 'Back', equipment: 'Barbell'),

    // ── Additional Shoulders ─────────────────────────────────
    Exercise(id: 'smith_ohp', name: 'Smith Machine Shoulder Press', muscleGroup: 'Shoulders', equipment: 'Smith Machine'),
    Exercise(id: 'cable_lat_raise', name: 'Cable Lateral Raise', muscleGroup: 'Shoulders', equipment: 'Cable'),
    Exercise(id: 'rear_delt_machine', name: 'Rear Delt Machine Fly', muscleGroup: 'Shoulders', equipment: 'Machine'),
    Exercise(id: 'plate_front_raise', name: 'Plate Front Raise', muscleGroup: 'Shoulders', equipment: 'Plate'),
    Exercise(id: 'db_shrug', name: 'Dumbbell Shrug', muscleGroup: 'Shoulders', equipment: 'Dumbbell'),
    Exercise(id: 'bb_shrug', name: 'Barbell Shrug', muscleGroup: 'Shoulders', equipment: 'Barbell'),
    Exercise(id: 'landmine_press', name: 'Landmine Press', muscleGroup: 'Shoulders', equipment: 'Barbell'),
    Exercise(id: 'single_landmine_press', name: 'Single Arm Landmine Press', muscleGroup: 'Shoulders', equipment: 'Barbell'),

    // ── Additional Biceps ────────────────────────────────────
    Exercise(id: 'ez_bar_curl', name: 'EZ Bar Curl', muscleGroup: 'Biceps', equipment: 'EZ Bar'),
    Exercise(id: 'incline_db_curl', name: 'Incline Dumbbell Curl', muscleGroup: 'Biceps', equipment: 'Dumbbell'),
    Exercise(id: 'cross_body_hammer', name: 'Cross Body Hammer Curl', muscleGroup: 'Biceps', equipment: 'Dumbbell'),
    Exercise(id: 'zottman_curl', name: 'Zottman Curl', muscleGroup: 'Biceps', equipment: 'Dumbbell'),
    Exercise(id: 'reverse_curl', name: 'Reverse Curl', muscleGroup: 'Biceps', equipment: 'EZ Bar'),
    Exercise(id: 'rope_curl', name: 'Rope Cable Curl', muscleGroup: 'Biceps', equipment: 'Cable'),

    // ── Additional Triceps ───────────────────────────────────
    Exercise(id: 'rope_pushdown', name: 'Rope Pushdown', muscleGroup: 'Triceps', equipment: 'Cable'),
    Exercise(id: 'single_arm_pushdown', name: 'Single Arm Pushdown', muscleGroup: 'Triceps', equipment: 'Cable'),
    Exercise(id: 'db_kickback', name: 'Dumbbell Kickback', muscleGroup: 'Triceps', equipment: 'Dumbbell'),
    Exercise(id: 'ez_skullcrusher', name: 'EZ Bar Skull Crusher', muscleGroup: 'Triceps', equipment: 'EZ Bar'),

    // ── Additional Quads ─────────────────────────────────────
    Exercise(id: 'smith_squat', name: 'Smith Machine Squat', muscleGroup: 'Quads', equipment: 'Smith Machine'),
    Exercise(id: 'bulgarian_split_squat', name: 'Bulgarian Split Squat', muscleGroup: 'Quads', equipment: 'Dumbbell'),
    Exercise(id: 'step_up', name: 'Step Up', muscleGroup: 'Quads', equipment: 'Dumbbell'),
    Exercise(id: 'wall_sit', name: 'Wall Sit', muscleGroup: 'Quads', equipment: 'Bodyweight'),
    Exercise(id: 'bodyweight_squat', name: 'Bodyweight Squat', muscleGroup: 'Quads', equipment: 'Bodyweight'),
    Exercise(id: 'landmine_squat', name: 'Landmine Squat', muscleGroup: 'Quads', equipment: 'Barbell'),

    // ── Additional Hamstrings / Glutes ───────────────────────
    Exercise(id: 'db_rdl', name: 'Dumbbell Romanian Deadlift', muscleGroup: 'Hamstrings', equipment: 'Dumbbell'),
    Exercise(id: 'good_morning', name: 'Good Morning', muscleGroup: 'Hamstrings', equipment: 'Barbell'),
    Exercise(id: 'single_leg_rdl', name: 'Single Leg Romanian Deadlift', muscleGroup: 'Hamstrings', equipment: 'Dumbbell'),
    Exercise(id: 'smith_hip_thrust', name: 'Smith Machine Hip Thrust', muscleGroup: 'Glutes', equipment: 'Smith Machine'),
    Exercise(id: 'frog_pump', name: 'Frog Pump', muscleGroup: 'Glutes', equipment: 'Bodyweight'),
    Exercise(id: 'single_leg_glute_bridge', name: 'Single Leg Glute Bridge', muscleGroup: 'Glutes', equipment: 'Bodyweight'),

    // ── Additional Calves ────────────────────────────────────
    Exercise(id: 'standing_calf_db', name: 'Standing Calf Raise (Dumbbell)', muscleGroup: 'Calves', equipment: 'Dumbbell'),
    Exercise(id: 'single_leg_calf', name: 'Single Leg Calf Raise', muscleGroup: 'Calves', equipment: 'Bodyweight'),
    Exercise(id: 'smith_calf_raise', name: 'Smith Machine Calf Raise', muscleGroup: 'Calves', equipment: 'Smith Machine'),

    // ── Forearms ─────────────────────────────────────────────
    Exercise(id: 'wrist_curl', name: 'Wrist Curl', muscleGroup: 'Forearms', equipment: 'Dumbbell'),
    Exercise(id: 'reverse_wrist_curl', name: 'Reverse Wrist Curl', muscleGroup: 'Forearms', equipment: 'Dumbbell'),
    Exercise(id: 'behind_back_wrist_curl', name: 'Behind Back Wrist Curl', muscleGroup: 'Forearms', equipment: 'Barbell'),
    Exercise(id: 'farmer_walk', name: 'Farmer Walk', muscleGroup: 'Forearms', equipment: 'Dumbbell'),

    // ── Additional Core ──────────────────────────────────────
    Exercise(id: 'hanging_knee_raise', name: 'Hanging Knee Raise', muscleGroup: 'Core', equipment: 'Bodyweight'),
    Exercise(id: 'dead_bug', name: 'Dead Bug', muscleGroup: 'Core', equipment: 'Bodyweight'),
    Exercise(id: 'reverse_crunch', name: 'Reverse Crunch', muscleGroup: 'Core', equipment: 'Bodyweight'),
    Exercise(id: 'heel_taps', name: 'Heel Taps', muscleGroup: 'Core', equipment: 'Bodyweight'),
    Exercise(id: 'mountain_climber', name: 'Mountain Climber', muscleGroup: 'Core', equipment: 'Bodyweight'),
    Exercise(id: 'v_up', name: 'V-Up', muscleGroup: 'Core', equipment: 'Bodyweight'),
    Exercise(id: 'landmine_rotation', name: 'Landmine Rotation', muscleGroup: 'Core', equipment: 'Barbell'),

    // ── Cardio ───────────────────────────────────────────────
    Exercise(id: 'jump_rope', name: 'Jump Rope', muscleGroup: 'Cardio', equipment: 'Bodyweight'),
    Exercise(id: 'treadmill_run', name: 'Treadmill Running', muscleGroup: 'Cardio', equipment: 'Machine'),
    Exercise(id: 'stationary_cycle', name: 'Stationary Cycling', muscleGroup: 'Cardio', equipment: 'Machine'),
    Exercise(id: 'burpee', name: 'Burpee', muscleGroup: 'Cardio', equipment: 'Bodyweight'),
    Exercise(id: 'high_knees', name: 'High Knees', muscleGroup: 'Cardio', equipment: 'Bodyweight'),
  ];
}
