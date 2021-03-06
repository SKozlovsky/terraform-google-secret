/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

terraform {
  required_version = "~> 0.11.7"
}

provider "google" {
  project     = "${var.project_name}"
  region      = "${var.region}"
  credentials = "${file(var.credentials_file_path)}"
}

provider "random" {}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  bucket_name = "random-bucket-${random_string.suffix.result}"
  file_object = "file.txt"
}

module "get_foo" {
  source = "../.."
  bucket = "${local.bucket_name}"
  path   = "/foo/${local.file_object}"
}

resource "google_storage_bucket_object" "foo" {
  name       = "/foo/${local.file_object}"
  source     = "${path.module}/${local.file_object}"
  bucket     = "${local.bucket_name}"
  depends_on = ["google_storage_bucket.test"]
}

resource "google_storage_bucket" "test" {
  name          = "${local.bucket_name}"
  force_destroy = "true"
}
