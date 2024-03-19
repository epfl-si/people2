import { Box, FormControl, MenuItem, Select } from '@mui/material';
import SelectInput from '@mui/material/Select/SelectInput';
import React from 'react';
import { useForm } from 'react-hook-form';

type ParamBarProps = {
	register: ReturnType<typeof useForm>['register'];
};

export default function ParamBar({ register }: ParamBarProps) {
	return (
		<Box flexDirection="row">
			Select the language:
			<Select {...register('showLang', { required: true })}>
				<MenuItem value="fr">French</MenuItem>
				<MenuItem value="en">English</MenuItem>
				<MenuItem value="bth">Both</MenuItem>
			</Select>
			Edit in the language:
			<Select {...register('editLang', { required: true })}>
				<MenuItem value="fr">French</MenuItem>
				<MenuItem value="en">English</MenuItem>
			</Select>
		</Box>
	);
}
