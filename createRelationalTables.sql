set foreign_key_checks = 0;
drop table if exists team;
drop table if exists game;
drop table if exists drive;
drop table if exists play;
set foreign_key_checks = 1;

create table if not exists team (
	team_id					integer not null auto_increment,
    team_abbr				char(3) not null,
    team_name				varchar(64) not null,
    team_city				varchar(64) not null,
    
    primary key (team_id)
);

create table if not exists game (
	game_id					integer not null auto_increment,
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
	drive_id				integer not null auto_increment,

	game_id					integer not null,
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
    
    primary key (drive_id),
    
    foreign key (game_id)
		references game(game_id),
	
    foreign key (team_id)
		references team(team_id)
);

create table if not exists play (
	play_id					integer not null auto_increment,
	game_id 				integer not null,
    team_id					integer not null,
    drive_id				integer not null,

	play_time				time not null,
    play_team_position		tinyint not null,
    play_down				tinyint not null,
    play_yds_to_first		tinyint unsigned not null,
    play_description		varchar(256) not null,
    play_note				varchar(64) not null,
    
    play_fd					tinyint not null,
    play_pass_fd			tinyint not null,
    play_rush_fd			tinyint not null,
    
    play_penalty			tinyint not null,
    play_penalty_fd			tinyint not null,
    play_penalty_yds		tinyint not null,
    
    
    
    primary key (play_id),
    
    foreign key (game_id, drive_id, team_id)
		references drive(game_id, drive_id, team_id)
);