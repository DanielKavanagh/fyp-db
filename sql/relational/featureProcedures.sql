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
drop procedure if exists homeAverageYardsPerPlay//
drop procedure if exists awayAverageYardsPerPlay//
drop procedure if exists overallAverageYardsPerPlay//
drop procedure if exists homeScoringEfficiency//
drop procedure if exists awayScoringEfficiency//
drop procedure if exists overallScoringEfficiency//
drop procedure if exists overallHomeFieldAdvantage//
drop procedure if exists teamOverallWinrate//

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
		select (sum(p.third_down_cmp) + sum(p.fourth_down_cmp)) / (sum(p.third_down_att)
			+ sum(p.fourth_down_att)) as conversionRate from (
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
		select (sum(p.third_down_cmp) + sum(p.fourth_down_cmp)) / (sum(p.third_down_att)
			+ sum(p.fourth_down_att)) as conversionRate from (
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

create procedure homeAverageYardsPerPlay(in teamID int, in gameID int,
	in numGames int, out averageYards float)
begin
	select sum(drive_yards_gained) / sum(drive_off_plays) from (
		select * from game
        where home_team_id = teamID
        and game_id < gameID
        order by game_id desc
        limit numGames) as lastGames
	join drive d on lastGames.game_id = d.game_id
    where d.team_id = teamID
    into averageYards;
end //

create procedure awayAverageYardsPerPlay(in teamID int, in gameID int,
	in numGames int, out averageYards float)
begin
	select sum(drive_yards_gained) / sum(drive_off_plays) from (
		select * from game
        where away_team_id = teamID
        and game_id < gameID
        order by game_id desc
        limit numGames) as lastGames
	join drive d on lastGames.game_id = d.game_id
    where d.team_id = teamID
    into averageYards;
end //

create procedure overallAverageYardsPerPlay(in teamID int, in gameID int,
	in numGames int, out averageYards float)
begin
	call homeAverageYardsPerPlay(teamID, gameID, numGames / 2, @homeAverage);
    call awayAverageYardsPerPlay(teamID, gameID, numGames / 2, @awayAverage);
    
    select (@homeAverage + @awayAverage) / 2 into averageYards;
end //

create procedure homeScoringEfficiency(in teamID int, in gameID int,
	in numGames int, out homeEfficiency float)
begin
	declare totalDrives int;
	declare scoringDrives int;

	select count(*) from (
		select * from game
		where home_team_id = teamID
        and game_id < gameID
        order by game_id desc
        limit numGames) as g
	join drive d on g.game_id = d.game_id
    where d.team_id = teamID
    and (d.drive_result = "Touchdown" or d.drive_result = "Field Goal")
    into scoringDrives;
                
	select count(*) from (
		select * from game
		where home_team_id = teamID
        and game_id < gameID
        order by game_id desc
        limit numGames) as g
	join drive d on g.game_id = d.game_id
    where d.team_id = teamID
    into totalDrives;
        
    select scoringDrives / totalDrives into homeEfficiency;
end //

create procedure awayScoringEfficiency(in teamID int, in gameID int,
	in numGames int, out awayEfficiency float)
begin
	declare totalDrives int;
	declare scoringDrives int;

	select count(*) from (
		select * from game
		where away_team_id = teamID
        and game_id < gameID
        order by game_id desc
        limit numGames) as g
	join drive d on g.game_id = d.game_id
    where d.team_id = teamID
    and (d.drive_result = "Touchdown" or d.drive_result = "Field Goal")
    into scoringDrives;
                
	select count(*) from (
		select * from game
		where away_team_id = teamID
        and game_id < gameID
        order by game_id desc
        limit numGames) as g
	join drive d on g.game_id = d.game_id
    where d.team_id = teamID
    into totalDrives;
        
    select scoringDrives / totalDrives into awayEfficiency;
end //

create procedure overallScoringEfficiency(in teamID int, in gameID int,
	in numGames int, out overallEfficiency float)
begin
	call homeScoringEfficiency(teamID, gameID, numGames / 2, @homeEfficiency);
    call awayScoringEfficiency(teamID, gameID, numGames / 2, @awayEfficiency);

	select (@homeEfficiency + @awayEfficiency) / 2 into overallEfficiency;
end //

create procedure overallHomeFieldAdvantage(in teamID int, in gameID int,
	out hfa float)
begin
	declare homePointDifferential float;
    declare awayPointDifferential float;
         
	select (sum(home_score_final) - sum(away_score_final)) / count(*) from game
    where home_team_id = teamID
    and game_id < gameID
    into homePointDifferential;
    
    select (sum(away_score_final) - sum(home_score_final)) / count(*) from game
    where away_team_id = teamID
    and game_id < gameID
    into awayPointDifferential;
    
    select (homePointDifferential - awayPointDifferential) into hfa;
end //

create procedure teamOverallWinrate(in teamID int, in gameID int, out wr float)
begin
	declare homeWins float;
    declare awayWins float;
    declare totalHomeGames int;
    declare totalAwayGames int;
    
    select count(*) from game
    where home_team_id = teamID
    and game_id < gameID
    into totalHomeGames;
    
    select count(*) from game
	where away_team_id = teamID
    and game_id < gameID
    into totalAwayGames;
    
	select count(*) from game
	where home_team_id = teamID
	and home_score_final > away_score_final
    and game_id < gameID
    into homeWins;
    
    select count(*) from game
	where away_team_id = teamID
    and away_score_final > home_score_final
    and game_id < gameID
    into awayWins;
    
    select (homeWins + awayWins) / (totalHomeGames + totalAwayGames) into wr;
    
end //
delimiter ;