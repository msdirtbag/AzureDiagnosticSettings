using './main.bicep'

//Parameters 

//Name of the resource group where the management resources will be deployed.
param mgmtresourcegroup = ''
//Subscription ID where the management resources will be deployed. 
param mgmtsubscription = ''

//Set to true if you want to deploy the second tier. (Incresed network visibility & log-ingest cost)
param deploytier2 = true
//Set to true if you want to deploy the third tier. (Incresed application visibility & log-ingest cost.***Not recommended for Sentinel-enabled Log Analytics workspaces)
param deploytier3 = true

//Log Analytics

//Region where the Log Analytics Workspace is deployed.
param loganalyticsregion = ''

//Name of the Log Analytics Workspace per tier.
param loganalytics1rid = ''
param loganalytics2rid = ''
param loganalytics3rid = ''

//Workspace ID of the Log Analytics Workspace for NSG Flow Logs.
param nsgflowlogworkspaceid = ''


