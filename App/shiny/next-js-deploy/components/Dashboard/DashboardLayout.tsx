import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectLabel,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"

import { ComboboxDemo } from "@/components/Dashboard/Components/ComboBox"

export default function DashboardLayout() {
  // Updated select with proper positioning
  const select = (
    <div className="relative w-fit">
      <Select>
        <SelectTrigger className="w-[180px]">
          <SelectValue placeholder="Select a fruit" />
        </SelectTrigger>
        <SelectContent
          position="item-aligned"
          sideOffset={4}
          align="center"
        >
          <SelectGroup>
            <SelectLabel>Fruits</SelectLabel>
            <SelectItem value="apple">Apple</SelectItem>
            <SelectItem value="banana">Banana</SelectItem>
            <SelectItem value="blueberry">Blueberry</SelectItem>
            <SelectItem value="grapes">Grapes</SelectItem>
            <SelectItem value="pineapple">Pineapple</SelectItem>
          </SelectGroup>
        </SelectContent>
      </Select>
    </div>
  )

  const combobox = '1'

  // You can also replace the other standard HTML selects with shadcn/ui ones
  const metricSelect = (
    <div className="relative w-full">
      <Select>
        <SelectTrigger className="w-full">
          <SelectValue placeholder="Select health metric" />
        </SelectTrigger>
        <SelectContent position="popper" align="center" sideOffset={4}>
          <SelectGroup>
            <SelectLabel>Health Metrics</SelectLabel>
            <SelectItem value="life-expectancy">Life Expectancy</SelectItem>
            <SelectItem value="obesity-rate">Obesity Rate</SelectItem>
            <SelectItem value="smoking-rate">Smoking Rate</SelectItem>
            <SelectItem value="healthcare-access">Access to Healthcare</SelectItem>
          </SelectGroup>
        </SelectContent>
      </Select>
    </div>
  )

  return (
    <section id="dashboard" className="mb-12">
      <h2 className="text-2xl font-bold mb-6">Interactive Dashboard</h2>

      <ComboboxDemo />


    </section>
  );
}