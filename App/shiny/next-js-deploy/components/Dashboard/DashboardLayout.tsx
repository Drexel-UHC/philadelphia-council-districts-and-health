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
      {select}

      <hr />
      <ComboboxDemo />
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {/* Map Panel */}
        <div className="md:col-span-2 bg-gray-100 rounded-lg p-4 min-h-[400px] shadow-md">
          <h3 className="text-xl mb-4">Philadelphia Council Districts Map</h3>
          <div className="bg-gray-200 h-[350px] flex items-center justify-center">
            {/* Map will be implemented here */}
            <p className="text-gray-500">Interactive map will be displayed here</p>
          </div>
        </div>

        {/* Controls Panel */}
        <div className="bg-gray-100 rounded-lg p-4 shadow-md">
          <h3 className="text-xl mb-4">Dashboard Controls</h3>

          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium mb-1">Select Health Metric</label>
              {metricSelect}
            </div>

            {/* You can similarly update the other selects */}
            <div>
              <label className="block text-sm font-medium mb-1">Select Year</label>
              <select className="w-full p-2 border rounded">
                <option>2023</option>
                <option>2022</option>
                <option>2021</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium mb-1">Filter by District</label>
              <select className="w-full p-2 border rounded">
                <option>All Districts</option>
                <option>District 1</option>
                <option>District 2</option>
                <option>District 3</option>
                {/* Add all districts */}
              </select>
            </div>
          </div>
        </div>

        {/* Data Visualization Panel */}
        <div className="md:col-span-3 bg-gray-100 rounded-lg p-4 shadow-md">
          <h3 className="text-xl mb-4">Health Metrics Analysis</h3>
          <div className="bg-gray-200 h-[300px] flex items-center justify-center">
            {/* Charts will be implemented here */}
            <p className="text-gray-500">Charts and data visualizations will be displayed here</p>
          </div>
        </div>
      </div>
    </section>
  );
}