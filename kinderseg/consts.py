import pandas as pd
import os



module_dir = os.path.dirname(__file__)
csv_path = os.path.join(module_dir, 'sumroi_mapping.csv')
sumroi_mapping = pd.read_csv(csv_path)