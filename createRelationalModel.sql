-- Create Relational Model Tables
drop table if exists drive;
drop table if exists game;
drop table if exists play;
drop table if exists team;
drop table if exists player;

create table if not exists team (
	team_id			integer not null,
    
    team_abbr		char(4) not null,
    team_name		varchar(128) not null,
    team_city		varchar(64) not null,
    
    primary key (team_id)
);

create table if not exists player (
	player_id			integer auto_increment not null,
    team_id				integer not null,
    			
    player_first_name	varchar(64) not null,
    player_last_name	varchar(64) not null,
    player_position		char(4) not null,
    player_dob			date not null,
    player_weight_lb	smallint unsigned not null,
    player_height_cm	smallint unsigned not null,
    player_college		varchar(64),
    player_years_exp	tinyint unsigned not null,
    player_uniform_num	tinyint unsigned not null,
    player_status		varchar(32) not null,
    player_profile_url	varchar(512) not null,
    
    primary key (player_id),
    
    foreign key (team_id)
		references team(team_id)
);

create table if not exists game (
	game_id					integer not null,
    game_eid				varchar(10) not null,
    
    home_team_id			integer not null,
    home_score_final		smallint unsigned not null,
    home_score_q1 			smallint unsigned not null,
    home_score_q2 			smallint unsigned not null,
    home_score_q3 			smallint unsigned not null,
    home_score_q4 			smallint unsigned not null,
    home_score_q5 			smallint unsigned not null,

    home_total_fds 			smallint not null,
    home_total_yds 			smallint not null,
    home_total_pass_yards 	smallint not null,
    home_total_rush_yards 	smallint not null,
    home_total_pens			smallint not null,
    home_total_pen_yards	smallint not null,
    home_time_of_pos		time not null,
    home_turnovers			smallint not null,
    home_total_punts		smallint not null,
    home_total_punt_yards	smallint not null,
    home_total_punt_avg		smallint not null,
    
    away_team_id			integer not null,
    away_score_final		smallint unsigned not null,
    away_score_q1 			smallint unsigned not null,
    away_score_q2 			smallint unsigned not null,
    away_score_q3 			smallint unsigned not null,
    away_score_q4 			smallint unsigned not null,
    away_score_q5 			smallint unsigned not null,
    
    away_total_fds 			smallint not null,
    away_total_yds 			smallint not null,
    away_total_pass_yards 	smallint not null,
    away_total_rush_yards 	smallint not null,
    away_total_pens			smallint not null,
    away_total_pen_yards	smallint not null,
    away_time_of_pos		time not null,
    away_turnovers			smallint not null,
    away_total_punts		smallint not null,
    away_total_punt_yards	smallint not null,
    away_total_punt_avg		smallint not null,
    
    game_week				tinyint not null,
    game_year				year(4) not null,
    game_type				char(4) not null,
    game_date				date not null,
    game_start_time			time not null,
    
    primary key (game_id),
    
    foreign key (home_team_id)
		references team(team_id),
        
	foreign key (away_team_id)
		references team(team_id)
);

create table if not exists drive (
	game_id					integer not null,
	drive_id				integer not null,
    team_id					integer not null,
    
    drive_pos_time			time not null,
    drive_total_plays 		tinyint unsigned not null,
    drive_first_downs		tinyint unsigned not null,
    drive_yards_gained		tinyint unsigned not null,
    drive_yards_pen			tinyint not null,
    drive_result			varchar(32) not null,
    			
	drive_start_time		time not null,
    drive_start_quarter		tinyint unsigned not null,
    drive_start_position	varchar(10) not null,
    
    drive_end_time			time not null,
    drive_end_quarter		tinyint unsigned not null,
    drive_end_position 		varchar(10) not null,
    
    primary key (game_id, drive_id),
    
    foreign key (game_id)
		references game(game_id),
        
	foreign key (team_id)
		references team(team_id)
);

create table if not exists play (
	game_id					integer not null,
    drive_id				integer not null,
	play_id					integer not null,
    team_id					integer not null,
    
    quarter					tinyint unsigned not null,
    down					tinyint unsigned not null,
    start_time				time not null,
    yard_line				varchar(10) not null,
    yards_to_first_down		tinyint unsigned not null,
	yards_this_drive		smallint not null,
    
    play_description		varchar(128) not null,
    play_note				varchar(64),
    
    type_id					integer not null,
    type_description		varchar(32) not null,
    
	first_down				tinyint(1) not null,
    rushing_first_down		tinyint(1) not null,
    passing_first_down		tinyint(1) not null,
    
    penalty					tinyint(1) not null,
    penalty_first_down		tinyint(1) not null,
    
    third_down_att			tinyint(1) not null,
    third_down_cmp			tinyint(1) not null,
    
    fourth_down_att			tinyint(1) not null,
    fourth_down_cmp			tinyint(1) not null,
    
    timeout					tinyint(1) not null,
    xp_aborted				tinyint(1) not null,
    
    primary key (game_id, drive_id, play_id),
    
    foreign key (game_id, drive_id)
		references drive(game_id, drive_id),
        
	foreign key (team_id)
		references team(team_id)
);

/*	
	Table: agg_play
    
    Description: Holds the aggregate statistics for a particular play. Has a one-to-one
	relationship with the play table. Prevents the need to perform aggregation
    multiple times. Has an attribute for each statistic a play can have.
    
    Play Categories:
		- Passing
        - Rushing
        - Receiving
        - Fumbles
        - Kicking
        - Punting
        - Kick Return
        - Punt Return 
        - Defense
        - Penalty
*/

create table if not exists agg_play (
	game_id					integer not null,
    drive_id				integer not null,
    play_id					integer not null,
    
    passing_att				tinyint(1) not null,
    passing_cmp				tinyint(1) not null,
    passing_cmp_air_yds		smallint not null,
    passing_cmp_tot_yds		smallint not null,
    passing_incmp			tinyint(1) not null,
    passing_incmp_air_yds	smallint,
    passing_int				tinyint(1) not null,
    passing_sack			tinyint(1) not null,
    passing_sack_yds		smallint not null,
    passing_td				tinyint(1) not null,
    passing_twopt_att		tinyint(1) not null,
    passing_twopt_cmp		tinyint(1) not null,
	passing_twopt_fail		tinyint(1) not null,

	
	rushing_att				tinyint(1) not null,
    rushing_yds				smallint not null,
    rushing_loss			tinyint(1) not null,
    rushing_loss_yds		smallint not null,
    rushing_td				tinyint(1) not null,
    rushing_twopt_att		tinyint(1) not null,
    rushing_two_point_cmp	tinyint(1) not null,
	rushing_two_point_fail	tinyint(1) not null,

    
    receiving_rec			tinyint(1) not null,
    receiving_target		tinyint(1) not null,
    receiving_yac_yds		smallint not null,
    receiving_tot_yds		smallint not null,
    receiving_twopt_att		tinyint(1) not null,
    receiving_twopt_cmp		tinyint(1) not null,
    receiving_twopt_fail	tinyint(1) not null,
    
    primary key (game_id, drive_id, play_id),
    
    foreign key (game_id, drive_id, play_id)
		references play(game_id, drive_id, play_id)
);

/*	
	Table: player_play
    
    Description: Contains the statistics for a particular player within a single play.
	Has a relationship with both the play & player table. 
*/

create table if not exists player_play (
	game_id			integer not null,
    drive_id		integer not null,
    play_id			integer not null,
    player_id		integer not null,
    
    primary key (game_id, drive_id, play_id, player_id),
    
    foreign key (game_id, drive_id, play_id)
		references play(game_id, drive_id, play_id),
        
	foreign key (player_id)
		references player(player_id)
);