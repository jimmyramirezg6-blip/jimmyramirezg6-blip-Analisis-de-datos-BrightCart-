## 📊 BrightCart Data Analysis Project

In proccess ...


## 📁 Project structure
```
BrightCart Project/
├── data/                   # Main folder for data
│   ├── raw/                # Original data (immutable, never overwritten)
│   └── processed/          # Clean and final data ready for modeling or visualization
│
├── notebooks/              # Jupyter notebooks
│   ├── 01_initial_exploration.ipynb
│   ├── 02_cleaning.ipynb
│   └── 03_visualizations.ipynb
│
├── outputs/                # Generated reports, presentations, or dashboards
│   └── figures/            # Plots and images exported from notebooks
│
├── sql/                    # Querys
│   ├── 00_staging.sql      # Kpis Querys
│   ├── 01_Kpis.sql         # Kpis Querys
│   ├── 02_Kpis.sql         # Kpis Querys
│   ├── 03_Kpis.sql         # Kpis Querys
│   └── README.md           # how to run it
│

│
├── .gitignore              # Files and folders that Git should ignore (e.g., /data/raw, .env)
├── README.md               # Main project documentation (objectives, how to run it)
└── requirements.txt        # Python dependencies (pandas, matplotlib, seaborn, etc.)

```


## How to Run the Staging Script

Before running the script, make sure you have **PostgreSQL** installed and that you're standing at the root of the repository (`proyecto_BrightCart`), since the script uses relative paths to read the CSVs from `data/processed/`.

### 1. Connect to the database

From a terminal, run:

```bash
psql -h localhost -U postgres -d brightcart
```

Enter the `postgres` user's password when prompted.

> **Note (Windows):** if `psql` is not recognized as a command, add the `bin` folder of your PostgreSQL installation (e.g. `C:\Program Files\PostgreSQL\18\bin`) to your system's `PATH` environment variable, or run the binary using its full path:
> ```powershell
> & "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h localhost -U postgres -d brightcart
> ```

### 2. Run the script

Once inside the `psql` console, run:

```sql
\i sql/00_staging.sql
```

This will create the necessary tables, load the data from `data/processed/`, and leave the database ready for analysis.

### Requirements

- PostgreSQL installed and running on `localhost`
- A database named `brightcart` already created
- The CSV files present in `data/processed/`


## 📌 Problema de negocio

The aim is to ensure the effectiveness of the campaigns implemented by the company.
## 👤 Autor

Jimmy Ramírez — [LinkedIn](https://www.linkedin.com/in/jimmy-ramirez-g) · [GitHub](https://github.com/jimmyramirezg6-blip)
