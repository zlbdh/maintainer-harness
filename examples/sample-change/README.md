# Sample Change Packet

This directory is a synthetic example. It shows the shape of a maintainer change packet without relying on private repositories or product-specific data.

The live workflow still writes generated change packets under `changes/<change-id>/`. Those generated packets are ignored by default because real projects may contain local paths, private branch names, or validation evidence.

Validate this sample from the repository root:

```powershell
.\scripts\checks\validate-change.ps1 -Path examples\sample-change
```
