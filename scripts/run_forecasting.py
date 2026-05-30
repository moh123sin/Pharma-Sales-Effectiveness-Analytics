from pathlib import Path
import pandas as pd
print(pd.read_csv(Path("data")/"model_metrics.csv").to_string(index=False))
print("Next-quarter forecast:")
print(pd.read_csv(Path("data")/"next_quarter_forecast.csv").to_string(index=False))
