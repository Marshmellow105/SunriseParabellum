import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { LabeledList, ProgressBar, Section } from '../components';
import { getGasColor, getGasLabel } from '../constants';
import { NtosWindow } from '../layouts';

export const NtosAtmos = (props) => {
  const { act, data } = useBackend();
  const { AirTempC, AirTempK, AirPressure } = data;
  const gases = flow([filter((gas) => gas.percentage >= 0.01), sortBy((gas) => -gas.percentage)])(data.AirData || []);
  const gasMaxPercentage = Math.max(1, ...gases.map((gas) => gas.percentage));
  return (
    <NtosWindow width={300} height={350}>
      <NtosWindow.Content scrollable>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Temperature">
              {AirTempC}°C | {AirTempK}K
            </LabeledList.Item>
            <LabeledList.Item label="Pressure">{AirPressure} kPa</LabeledList.Item>
          </LabeledList>
        </Section>
        <Section>
          <LabeledList>
            {gases.map((gas) => (
              <LabeledList.Item key={gas.name} label={getGasLabel(gas.name)}>
                <ProgressBar color={getGasColor(gas.name)} value={gas.percentage} minValue={0} maxValue={gasMaxPercentage}>
                  {toFixed(gas.percentage, 2) + '%'}
                </ProgressBar>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
