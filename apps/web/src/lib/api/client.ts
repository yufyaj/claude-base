import createClient from "openapi-fetch";
import type { paths } from "./schema";

export const apiClient = createClient<paths>({
	baseUrl: process.env.API_BASE_URL || "http://localhost:8000",
});
