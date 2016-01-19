create table if not exists game (
	
    /*Game Properties*/
    game_id					integer not null auto_increment,
    gamecenter_key			varchar(12) not null,
    
    game_week				tinyint not null,
    game_year				year(4) not null,
    game_type				char(4) not null,
    game_date				date not null,
    game_start_time			time not null,
    
    /*Home Team*/
    home_abbr				char(4) not null,
    home_name				varchar(128) not null,
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
    
    /*Away Team*/
    away_abbr				char(4) not null,
    away_name				varchar(128) not null,
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
    
    primary key (game_id)
    
)engine=InnoDB;

create table if not exists drive (
	
    drive_id				integer not null auto_increment,
    game_id					integer not null,
    
    start_quarter			smallint not null,
    start_time				time not null,
    start_position			smallint not null,
    
    end_quarter				smallint not null,
    end_time				time not null,
    end_position			smallint not null,
    
    pos_team_abbr			char(4) not null,
    pos_time				time not null,
    
    first_downs				smallint not null,
    number_plays			smallint not null,
    yards_gained			smallint not null,
    penalty_yards			smallint not null,
    result					varchar(64) not null,
    
	primary key (drive_id),
    
    foreign key (game_id)
		references game(game_id)
        on update cascade
		on delete restrict
    
)engine=InnoDB;

create table if not exists play (
	
    play_id					integer not null auto_increment,
    game_id					integer not null,
    drive_id				integer not null,
    
    pos_team_abbr			char(4) not null,
    
    play_quarter			smallint not null,
    play_down				smallint not null,
    play_time				time not null,
    play_description		varchar(256) not null,
    play_note 				varchar(64) not null
);