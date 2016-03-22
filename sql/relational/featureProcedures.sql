delimiter //

drop procedure if exists aggregateHomeTeamWinRate//
drop procedure if exists aggregateAwayTeamWinRate//
drop procedure if exists aggregateOverallTeamWinRate//
drop procedure if exists homeWinRateAgainstAway//
drop procedure if exists awayWinRateAgainstHome//
drop procedure if exists aggregateHomeTurnoverRate//
drop procedure if exists aggregateAwayTurnoverRate//
drop procedure if exists aggregateOverallTurnoverRate//
drop procedure if exists homeTimeOfPossession//
drop procedure if exists awayTimeOfPossession//
drop procedure if exists overallTimeOfPossession//
drop procedure if exists homeScoringEfficiency//
drop procedure if exists homeThirdAndFourthConversionRate//
drop procedure if exists awayThirdAndFourthConversionRate//
drop procedure if exists overallThirdAndFourthConversionRate//

/*Aggregates the home win rate (using the last 8 samples) of a team for a given game*/
create procedure aggregateHomeTeamWinRate(in teamID int, in gameID int, in numGames int, out winRate float)
begin
	select (count(*) / numGames) as home_win_rate from (select * from game 
		where home_team_id = teamID
        and game_id <= gameID
        order by game_eid desc
        limit numGames) as lastSeasonHomeGames
	where home_score_final > away_score_final
    into winRate;
end //

/*Aggregates the away win rate (using the last 8 samples) of a team for a given game*/
create procedure aggregateAwayTeamWinRate(in teamID int, in gameID int, in numGames int, out winRate float)
begin
	select (count(*) / numGames) from (select * from game 
		where away_team_id = teamID
        and game_id <= gameID
        order by game_eid desc
        limit numGames) as lastSeasonAwayGames
	where away_score_final > home_score_final
    into winRate;
end //

create procedure aggregateOverallTeamWinRate(in teamID int, in gameID int, in numGames int,
	out winRate float)
begin
	call aggregateHomeTeamWinRate(teamID, gameID, numGames / 2, @homeWinRate);
    call aggregateAwayTeamWinRate(teamID, gameID, numGames / 2, @awayWinRate);
    
    select (@homeWinRate + @awayWinRate) / 2 into winRate;
end //

create procedure homeWinRateAgainstAway(in homeTeam int, in awayTeam int, in gameID int,
	out homeTeamWinRate float)
begin
	declare numGamesBetweenTeams int;

	select count(*) from game where game_id <= gameID
    and home_team_id = homeTeam and away_team_id = awayTeam
    and home_score_final != away_score_final
    into numGamesBetweenTeams;
            
	select (count(*) / numGamesBetweenTeams) from game where game_id <= gameID
    and home_team_id = homeTeam and away_team_id = awayTeam
    and home_score_final > away_score_final
    order by game_eid desc
    into homeTeamWinRate;    
end //

create procedure awayWinRateAgainstHome(in homeTeam int, in awayTeam int, in gameID int,
	out awayTeamWinRate float)
begin
	declare numGamesBetweenTeams int;
    
	select count(*) from game where game_id <= gameID
    and home_team_id = homeTeam and away_team_id = awayTeam
    and home_score_final != away_score_final
    into numGamesBetweenTeams;
    
	select (count(*) / numGamesBetweenTeams) from game where game_id <= gameID
    and home_team_id = homeTeam and away_team_id = awayTeam
    and away_score_final > home_score_final
    order by game_eid desc
    into awayTeamWinRate;
end //
create procedure aggregateHomeTurnoverRate(in teamID int, in gameID int,
	in numGames int, out turnoverRate float)
begin
	select sum(home_turnovers) / count(*) from (select * from game
		where home_team_id = teamID
        and game_id <= gameID 
        order by game_id desc
        limit numGames) as lastHomeGames
	into turnoverRate;
end //

create procedure aggregateAwayTurnoverRate(in teamID int, in gameID int,
	in numGames int, out turnoverRate float)
begin
	select sum(away_turnovers) / count(*) from (select * from game
		where away_team_id = teamID
        and game_id <= gameID 
        order by game_id desc
        limit numGames) as lastAwayGames
	into turnoverRate;
end //

create procedure aggregateOverallTurnoverRate(in teamID int, in gameID int,
	in numGames int, out turnoverRate float)
begin
	call aggregateHomeTurnoverRate(teamID, gameID, numGames / 2, @homeTurnoverRate);
    call aggregateAwayTurnoverRate(teamID, gameID, numGames / 2, @awayTurnoverRate);
    
    select (@homeTurnoverRate + @awayTurnoverRate) / 2
    into turnoverRate;
end //

-- create procedure homeScoringEfficiency(in teamID int, in gameID int,
-- 	in numGames int)
-- begin
--     
-- 	select 1 - (lastHomeGames.home_turnovers + lastHomeGames.home_total_punts) / count(d.game_id)
-- 		as scoring_efficiency
--     from (select * from game
-- 		where home_team_id = teamID
-- 		and game_id <= gameID
-- 		order by game_id desc
-- 		limit numGames) as lastHomeGames
-- 	left join drive d on lastHomeGames.game_id = d.game_id
--     where d.team_id = teamID
--     group by lastHomeGames.game_id
--     order by lastHomeGames.game_id desc;    
-- end //

create procedure homeTimeOfPossession(in teamID int, in gameID int,
	in numGames int, out topRate float)
begin    
    select AVG((TIME_TO_SEC(lastNumGames.home_top)) / (TIME_TO_SEC(lastNumGames.away_top) + TIME_TO_SEC(lastNumGames.home_top))) as homeTopRatio
    from (
		select STR_TO_DATE(home_time_of_pos, '%i:%s') as home_top,
		STR_TO_DATE(away_time_of_pos, '%i:%s') as away_top
		from game
		where home_team_id = teamID
        and game_id <= gameID
        order by game_id desc
        limit numGames) 
	as lastNumGames
    into topRate;
end //

create procedure awayTimeOfPossession(in teamID int, in gameID int,
	in numGames int, out topRate float)
begin    
    select AVG((TIME_TO_SEC(lastNumGames.away_top)) / (TIME_TO_SEC(lastNumGames.home_top) + TIME_TO_SEC(lastNumGames.away_top))) as awayTopRatio
    from (
		select STR_TO_DATE(home_time_of_pos, '%i:%s') as home_top,
		STR_TO_DATE(away_time_of_pos, '%i:%s') as away_top
		from game
		where away_team_id = teamID
        and game_id <= gameID
        order by game_id desc
        limit numGames) 
	as lastNumGames
    into topRate;
end //

create procedure overallTimeOfPossession(in teamID int, in gameID int,
	in numGames int, out overallTop float)
begin
	call homeTimeOfPossession(teamID, gameID, numGames / 2, @homeAvgTop);
    call awayTimeOfPossession(teamID, gameID, numGames / 2, @awayAvgTop);
    
    select (@homeAvgTop + @awayAvgTop) / 2 into overallTop;    
end //

create procedure homeThirdAndFourthConversionRate(in teamID int, in gameID int,
	in numGames int, out conversionRate float)
begin
	select (sum(p.third_down_cmp) + sum(p.fourth_down_att)) / (sum(p.third_down_att) + sum(p.fourth_down_att)) as conversionRate from (
		select * from game
        where home_team_id = teamID
        and game_id < gameID
        order by game_id desc
        limit numGames) as lastGames
	join drive d on lastGames.game_id = d.game_id
    join play p on (d.drive_id = p.drive_id and lastGames.game_id = p.game_id)
    where p.team_id = teamID
    and (p.third_down_att = 1 or p.fourth_down_att = 1)
    into conversionRate;
end //

create procedure awayThirdAndFourthConversionRate(in teamID int, in gameID int,
	in numGames int, out conversionRate float)
begin
	select (sum(p.third_down_cmp) + sum(p.fourth_down_att)) / (sum(p.third_down_att) + sum(p.fourth_down_att)) as conversionRate from (
		select * from game
        where away_team_id = teamID
        and game_id < gameID
        order by game_id desc
        limit numGames) as lastGames
	join drive d on lastGames.game_id = d.game_id
    join play p on (d.drive_id = p.drive_id and lastGames.game_id = p.game_id)
    where p.team_id = teamID
    and (p.third_down_att = 1 or p.fourth_down_att = 1)
    into conversionRate;
end //

create procedure overallThirdAndFourthConversionRate(in teamID int, in gameID int,
	in numGames int, out conversionRate float)
begin
	call homeThirdAndFourthConversionRate(teamID, gameID, numGames / 2, @homeRate);
    call awayThirdAndFourthConversionRate(teamID, gameID, numGames / 2, @awayRate);
    
    select (@homeRate + @awayRate) / 2 into conversionRate;
end //

delimiter ;

-- call overallThirdAndFourthConversionRate(28, 1792, 16, @result);
-- select @result;
-- 
-- call homeScoringEfficiency(20, 1792, 8);
-- 
-- create procedure homeScoringEfficiency(in teamID int, in gameID int,
-- 	in numGames int)
-- begin    
--     select sum(d.drive_yards_gained) / sum(d.drive_off_plays) from (
-- 		select * from game
-- 		where home_team_id = teamID
--         and game_id <= gameID
--         order by game_id desc
--         limit numGames) 
-- 	as lastGames
--     left join drive d on lastGames.game_id = d.game_id
--     where d.team_id = teamID;
-- end //
-- 

-- call homeWinRateAgainstAway(25, 26, 1792, @wr);
-- select @wr;
-- call overallTimeOfPossession(26, 1792, 16, @overallTop);
-- select @overallTop;
--
-- -- call aggregateOverallTurnoverRate(13, 1512, 16, @otr);
-- select @otr;
-- 
-- call aggregateHomeTurnoverRate(1, 1792, 8, @htr);
-- select @htr;
-- call aggregateAwayTurnoverRate(1, 1792, 8, @atr);
-- select @atr;
-- 
-- call aggregateWinRateAgainstTeam(30, 32, 1792, @htwr, @atwr);
-- select @htwr as home_team_wr_against_away;
-- select @atwr as away_team_wr_against_home;
-- 
-- call aggregateHomeTeamWinRate(3, 1792, 8, @hwr);
-- select @hwr as home_win_rate;
-- call aggregateAwayTeamWinRate(3, 1792, 8, @awr);
-- select @awr as away_win_rate;
-- call aggregateOverallTeamWinRate(3, 1792, 16);
