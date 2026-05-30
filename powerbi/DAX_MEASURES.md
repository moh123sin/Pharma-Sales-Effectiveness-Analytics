# DAX Measures
```DAX
Total Revenue = SUM(sales[revenue])
Units Sold = SUM(sales[units_sold])
Total Calls = SUM(call_activity[calls])
Total Visits = SUM(call_activity[visits])
Incentive Paid = SUM(incentive_compensation[bonus])
Target Revenue = SUM(incentive_compensation[target_revenue])
Achievement % = DIVIDE(SUM(incentive_compensation[actual_revenue]), [Target Revenue], 0)
Revenue Previous Month = CALCULATE([Total Revenue], DATEADD('Calendar'[Date], -1, MONTH))
Sales Growth % = DIVIDE([Total Revenue] - [Revenue Previous Month], [Revenue Previous Month], 0)
Revenue per Call = DIVIDE([Total Revenue], [Total Calls], 0)
Conversion Rate % = DIVIDE([Units Sold], [Total Calls], 0)
Rep Rank by Revenue = RANKX(ALL(reps[rep_name]), [Total Revenue],, DESC, Dense)
```
