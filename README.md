# Laptop Dataset Cleaning with SQL

This repository contains the SQL scripts and documentation for cleaning an uncleaned laptop dataset. The goal of this project was to modularize the raw data into more useful columns, making it suitable for building a predictive model to estimate laptop prices.

## Project Overview

The original dataset contained several columns with unstructured and combined data. Through the cleaning process, the dataset was transformed into a more organized format with separate columns for key attributes. This modularization allows for more effective data analysis and model building.

### Dataset Description Before Cleaning

| Column Name        | Data Type     | Nullable |
|--------------------|---------------|----------|
| Unnamed: 0         | int(11)       | YES      |
| Company            | text          | YES      |
| TypeName           | text          | YES      |
| Inches             | double        | YES      |
| ScreenResolution   | text          | YES      |
| Cpu                | text          | YES      |
| Ram                | text          | YES      |
| Memory             | text          | YES      |
| Gpu                | text          | YES      |
| OpSys              | text          | YES      |
| Weight             | text          | YES      |
| Price              | double        | YES      |

### Dataset Description After Cleaning

| Column Name        | Data Type        | Nullable |
|--------------------|------------------|----------|
| id                 | int(11)          | YES      |
| Company            | text             | YES      |
| TypeName           | text             | YES      |
| Inches             | double           | YES      |
| resolution_width   | int(11)          | YES      |
| resolution_height  | int(11)          | YES      |
| screentype         | varchar(225)     | YES      |
| touchscreen        | int(11)          | YES      |
| cpu_brand          | varchar(255)     | YES      |
| cpu_name           | varchar(255)     | YES      |
| cpu_speed          | decimal(10,1)    | YES      |
| Ram                | int(11)          | YES      |
| memory_type        | varchar(255)     | YES      |
| primary_storage    | int(11)          | YES      |
| secondary_storage  | int(11)          | YES      |
| gpu_brand          | varchar(255)     | YES      |
| gpu_name           | varchar(255)     | YES      |
| OpSys              | text             | YES      |
| Weight             | int(11)          | YES      |
| Price              | int(11)          | YES      |

### Key Cleaning Steps

1. **Screen Resolution**: Split the `ScreenResolution` column into `resolution_width` and `resolution_height` for more granular analysis.
2. **Screen Type**: Extracted screen type information into the `screentype` column.
3. **Touchscreen**: Created a binary `touchscreen` column indicating the presence of a touchscreen.
4. **CPU**: Parsed the `Cpu` column into `cpu_brand`, `cpu_name`, and `cpu_speed` to capture brand, model, and speed separately.
5. **Memory**: Split the `Memory` column into `memory_type`, `primary_storage`, and `secondary_storage` for clearer storage details.
6. **GPU**: Separated the `Gpu` column into `gpu_brand` and `gpu_name`.
7. **Weight**: Converted the `Weight` column to a numeric format for easier use in models.

## Usage

This repository is aimed at data professionals and enthusiasts who want to explore how SQL can be used for effective data cleaning. You can explore the scripts and adapt them to similar datasets in your projects.

## Future Work

- **Model Building**: Use the cleaned data to build a predictive model for laptop prices.
- **Further Optimization**: Refine data types and cleaning steps to improve model accuracy.
