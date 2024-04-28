import { application } from "controllers/application";

import tables from "@katalyst/tables";

application.load(tables);

import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading";
eagerLoadControllersFrom("controllers", application);
