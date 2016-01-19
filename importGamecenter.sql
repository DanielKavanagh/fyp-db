drop table Import_Game_Data;
drop table Import_Game_Player_Stats;

create table if not exists Import_Game_Data (

	game_id					integer unsigned auto_increment,
    
	home_abbr 				char(4),
    home_score				tinyint unsigned,
    home_score_q1 			tinyint unsigned,
    home_score_q2 			tinyint unsigned,
    home_score_q3 			tinyint unsigned,
    home_score_q4 			tinyint unsigned,
    home_score_q5 			tinyint unsigned,
    	 			
    home_total_fds 			smallint,
    home_total_yds 			smallint,
    home_total_pass_yards 	smallint,
    home_total_rush_yards 	smallint,
    home_total_pens			smallint,
    home_total_pen_yards	smallint,
    home_time_of_pos		smallint,
    home_turnovers			smallint,
    home_total_punts		smallint,
    home_total_punt_yards	smallint,
    home_total_punt_avg		smallint,
    
    away_abbr 				char(4),
    away_score_fnl 			tinyint unsigned,
    away_score_q1 			tinyint unsigned,
    away_score_q2 			tinyint unsigned,
    away_score_q3 			tinyint unsigned,
    away_score_q4 			tinyint unsigned,
    away_score_q5 			tinyint unsigned,
    
	away_total_fds 			smallint,
    away_total_yds 			smallint,
    away_total_pass_yards 	smallint,
    away_total_rush_yards 	smallint,
    away_total_pens			smallint,
    away_total_pen_yards	smallint,
    away_time_of_pos		smallint,
    away_turnovers			smallint,
    away_total_punts		smallint,
    away_total_punt_yards	smallint,
    away_total_punt_avg		smallint,
    
    constraint pk_import_game primary key (game_id)
    
);

create table if not exists Game_Player_Stats (
	
    game_id					integer unsigned,
    stat_id					integer unsigned auto_increment,
    
	stat_type				varchar(20),
    player_name				varchar(128),
    
    passing_attempts		smallint,
    passing_completed		smallint,
    passing_yards			smallint,
    passing_touchdowns		smallint,
    passing_interceptions	smallint,
    passing_two_point_att	smallint,
    passing_two_point_cmp	smallint,
    
    rushing_attempts		smallint,
    rushing_yards			smallint,
    rushing_touchdowns		smallint,
    rushing_long			smallint,
    rushing_two_point_att	smallint,
    rushing_two_point_cmp	smallint,
    
    receiving_receptions	smallint,
    receiving_yards			smallint,
    receiving_touchdowns	smallint,
    receiving_long			smallint,
    receiving_two_point_att	smallint,
    receiving_two_point_cmp	smallint,
    
    kicking_fg_cmp			smallint,
    kicking_fg_att			smallint,
    kicking_fg_yds			smallint,
    kicking_fg_points		smallint,
    kicking_xp_cmp			smallint,
    kicking_cp_msd			smallint,
    kicking_xp_att			smallint,
    kicking_xp_points		smallint,
    
    punting_punts			smallint,
    punting_yds_total		smallint,
    punting_yds_average		smallint,
    punting_yds_long		smallint,
    
    kick_return_returns		smallint,
    kick_return_average		smallint,
    kick_return_tds			smallint,
    kick_return_long		smallint,
    
    punt_return_returns		smallint,
    punt_return_average		smallint,
    punt_return_tds			smallint,
    punt_return_long		smallint,
    
    defence_tackles			smallint,
    defence_sacks			smallint,
    defence_ints			smallint,
    defence_forced_fumbles	smallint,	
    defence_assists			smallint,
    
    constraint pk_import_game_stats primary key (stat_id),
    
    foreign key (game_id)
		references Import_Game_Data(game_id)
			on update cascade
			on delete restrict    
);

create table Game_Drive (
	
    game_id				integer unsigned,
    drive_id			integer unsigned auto_increment,
    
    team_possession		char(4),
    first_downs			tinyint,
    pen_yards			smallint,
    number_plays		smallint,
    possession_time		smallint,
    result				varchar(64),
    
    start_quarter		tinyint,
    start_time			time,
    start_yard_line		smallint,
    start_team			char(4),
    
    end_quarter			tinyint,
    end_time			time,
    end_yard_line		smallint,
    end_team			char(4),
    
    primary key (drive_id)
    
    foreign key 
    
);