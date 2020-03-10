resource "aws_glue_catalog_database" "pdm_dataset_generation" {
  name        = "pdm_dataset_generation"
  description = "Database for the Manifest comparision ETL"
}

output "pdm_dataset_generation" {
  value = {
    job_name = aws_glue_catalog_database.pdm_dataset_generation.name
  }
}