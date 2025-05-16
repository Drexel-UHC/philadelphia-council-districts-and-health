import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectLabel,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"

import { SelectMetric } from "@/components/Dashboard/Components/SelectMetric"

export default function DashboardLayout() {


  return (
    <section id="dashboard" className="mb-12">
      <h2 className="text-2xl font-bold mb-6">Interactive Dashboard</h2>
      <SelectMetric />
    </section>
  );
}