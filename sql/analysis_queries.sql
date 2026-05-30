USE pharma_sales_analytics;
-- 1 Top reps: joins + CTE + window rank
WITH rep_kpis AS (SELECT r.rep_id,r.rep_name,r.manager,r.territory,r.region,SUM(s.revenue) total_revenue,SUM(s.units_sold) units_sold,SUM(c.calls) total_calls,COUNT(DISTINCT s.doctor_id) doctors_engaged,ROUND(SUM(s.revenue)/NULLIF(SUM(c.calls),0),2) revenue_per_call FROM reps r JOIN sales s ON r.rep_id=s.rep_id JOIN call_activity c ON s.activity_id=c.activity_id GROUP BY r.rep_id,r.rep_name,r.manager,r.territory,r.region) SELECT *,DENSE_RANK() OVER(ORDER BY total_revenue DESC) revenue_rank FROM rep_kpis ORDER BY revenue_rank LIMIT 15;
-- 2 Territory contribution and rank
WITH t AS (SELECT region,territory,SUM(revenue) territory_revenue,SUM(units_sold) units_sold FROM sales GROUP BY region,territory) SELECT *,ROUND(100*territory_revenue/SUM(territory_revenue) OVER(),2) revenue_contribution_pct,DENSE_RANK() OVER(PARTITION BY region ORDER BY territory_revenue DESC) rank_in_region FROM t ORDER BY region,rank_in_region;
-- 3 Doctor engagement
SELECT d.doctor_id,d.doctor_name,d.specialty,d.potential_class,SUM(c.calls) total_calls,SUM(c.visits) visits,ROUND(AVG(c.engagement_score),3) avg_engagement_score,SUM(s.revenue) revenue_generated,ROUND(SUM(s.revenue)/NULLIF(SUM(c.calls),0),2) revenue_per_call FROM doctors d JOIN call_activity c ON d.doctor_id=c.doctor_id JOIN sales s ON c.activity_id=s.activity_id GROUP BY d.doctor_id,d.doctor_name,d.specialty,d.potential_class ORDER BY revenue_generated DESC LIMIT 25;
-- 4 Incentive audit and rank
SELECT i.month,r.rep_name,r.manager,r.territory,i.target_revenue,i.actual_revenue,i.achievement_pct,i.performance_band,i.bonus,DENSE_RANK() OVER(PARTITION BY i.month ORDER BY i.achievement_pct DESC) monthly_rank FROM incentive_compensation i JOIN reps r ON i.rep_id=r.rep_id ORDER BY i.month,monthly_rank;
-- 5 Monthly growth with LAG
WITH m AS (SELECT month,SUM(revenue) total_revenue,SUM(units_sold) units_sold FROM sales GROUP BY month),x AS (SELECT *,LAG(total_revenue) OVER(ORDER BY month) previous_month_revenue FROM m) SELECT *,ROUND(100*(total_revenue-previous_month_revenue)/NULLIF(previous_month_revenue,0),2) mom_growth_pct FROM x ORDER BY month;
-- 6 Below-target coaching list
SELECT i.month,r.rep_name,r.manager,r.territory,i.target_revenue,i.actual_revenue,i.achievement_pct,ROUND(i.target_revenue-i.actual_revenue,2) revenue_gap FROM incentive_compensation i JOIN reps r ON i.rep_id=r.rep_id WHERE i.achievement_pct<90 ORDER BY i.month DESC,revenue_gap DESC;
-- 7 Rolling territory revenue
WITH m AS (SELECT territory,month,SUM(revenue) monthly_revenue FROM sales GROUP BY territory,month) SELECT territory,month,monthly_revenue,ROUND(SUM(monthly_revenue) OVER(PARTITION BY territory ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) rolling_3m_revenue FROM m ORDER BY territory,month;
