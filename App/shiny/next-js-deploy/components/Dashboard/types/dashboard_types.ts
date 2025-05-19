export interface MetricData {
  district: string;
  var_name: string;
  value: number;
  city_avg: number;
  var_label: string;
  var_def: string;
  source: string;
  year: string;
  aggregation_notes: string;
  cleaning_notes: string | null;
  ylabs: string;
  district_int: number;
  source_year: string;
  value_clean: string;
}

export interface MetricMetadata {
  var_label: string;
  var_def: string;
  source: string;
  year: string;
  var_name: string;
  ylabs: string;
}